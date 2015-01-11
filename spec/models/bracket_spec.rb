require "spec_helper"

describe Bracket, type: :model do
  subject { create(:bracket) }


  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { should belong_to(:user) }
  it { should belong_to(:payment_collector) }
  it { should have_many(:picks) }
  it { should have_one(:charge) }

  it { should validate_presence_of(:user) }
  it { should validate_uniqueness_of(:name) }

  context "accessible attributes" do
    let(:another_user) { create(:user) }

    it "allows setting of tie_breaker, name, points, and possible_points" do
      subject.update_attributes(tie_breaker: 2, name: "new name", points: 10, possible_points: 12)
      subject.reload

      expect(subject.tie_breaker).to eq(2)
      expect(subject.name).to eq("new name")
      expect(subject.points).to eq(10)
      expect(subject.possible_points).to eq(12)
    end

    it "does not allow setting of user_id or payment_collector_id" do
      expect { subject.update_attributes(user_id: another_user.id) }.to raise_exception
      expect { subject.update_attributes(payment_collector_id: another_user.id) }.to raise_exception
    end
  end

  context "after create" do
    let!(:games) { create_list(:game, 5) }

    it "creates all picks" do
      games.each do |game|
        expect(subject.picks.find_by_game_id(game.id)).to be_present
      end
    end
  end

  context "before validation" do
    it "resets tie_breaker to nil if it is <= 0" do
      subject.tie_breaker = 0
      expect(subject).to be_valid
      expect(subject.tie_breaker).to be_nil
    end

    it "gives the bracket a default name if the name is blank" do
      user = create(:user)
      bracket = build(:bracket, user: user)

      expected_name = bracket.default_name

      bracket.save!

      expect(bracket.name).to eq(expected_name)
    end
  end

  context "payment_state state machine" do
    it "starts with :unpaid" do
      expect(subject).to be_unpaid
    end

    context "unpaid state" do
      context "and a promise_made event is fired" do
        before { subject.promise_made! }

        it "transitions to :promised state" do
          expect(subject).to be_promised
        end
      end

      context "and a payment_recieved event is fired" do
        before { subject.payment_received! }

        it "transitions to :paid state" do
          expect(subject).to be_paid
        end
      end
    end

    context "promised state" do
      before { subject.promise_made! }

      it "is promised?" do
        expect(subject).to be_promised
      end

      context "and a payment_recieved event is fired" do
        before { subject.payment_received! }

        it "transitions to :paid state" do
          expect(subject).to be_paid
        end
      end
    end

    context "paid state" do
      before { subject.payment_received! }

      it "is paid?" do
        expect(subject).to be_paid
      end
    end
  end

  context "#status" do
    context "with an incomplete bracket" do
      it "is :incomplete" do
        expect(subject.status).to eq(:incomplete)
      end
    end

    context "with a complete bracket" do
      subject { create(:bracket, :completed) }

      before { build(:tournament) }

      context "and it is unpaid" do
        it "is :unpaid" do
          expect(subject.status).to eq(:unpaid)
        end
      end

      context "and it is promised" do

        before { subject.promise_made! }

        it "is :ok" do
          expect(subject.status).to eq(:ok)
        end
      end

      context "and it is paid" do
        before { subject.payment_received! }

        it "is :ok" do
          expect(subject.status).to eq(:ok)
        end
      end
    end
  end

  context "#only_bracket_for_user?" do
    context "when the user has a single bracket" do
      it "returns true" do
        expect(subject.user.brackets.count).to eq(1)
        expect(subject).to be_only_bracket_for_user
      end
    end

    context "when the user has multiple brackets" do
      let!(:another_bracket) { create(:bracket, user: subject.user) }

      it "returns false" do
        expect(subject).to_not be_only_bracket_for_user
      end
    end
  end

  context "#default_name" do
    it "is the user's name" do
      expect(subject.name).to eq(subject.user.name)
    end

    context "when a bracket with the user's name exists" do
      let(:another_bracket) { build(:bracket, user: subject.user) }

      it "increments an integer and adds it to the end of the name until unique" do
        expect(another_bracket.default_name).to eq("#{subject.user.name} 1")
      end
    end
  end

  context "#complete? / #incomplete?" do
    subject { create(:bracket, :completed) }
    before { build(:tournament) }

    it "is complete when all picks are selected and a tie_breaker is set" do
      expect(subject.picks.where(team_id: nil)).to be_empty
      expect(subject.tie_breaker).to be > 0

      expect(subject).to be_complete
    end

    context "when a pick.team is nil" do
      before { subject.picks.to_a.sample.update_attribute(:team_id, nil) }

      it "is incomplete" do
        expect(subject).to be_incomplete
      end
    end

    context "when a pick.team_id is -1" do
      before { subject.picks.to_a.sample.update_attribute(:team_id, -1) }

      it "is incomplete" do
        expect(subject).to be_incomplete
      end
    end

    context "when a tie_breaker is blank" do
      before { subject.update_attribute(:tie_breaker, nil) }

      it "is incomplete" do
        expect(subject).to be_incomplete
      end
    end
  end

  context "#calculate_points" do
    it "is the sum of all the picks' points"
    it "updates the #points attribute"
  end

  context "#sorted_four" do
    it "is the teams of final four picks of the bracket"
    it "is ordered by champ, second, game_one.loser, game_two.loser"
  end

end
