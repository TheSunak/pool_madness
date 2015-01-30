require "spec_helper"

describe PossibleOutcome, type: :model do
  before(:all) { build(:tournament) }
  let!(:brackets) { create_list(:bracket, 5) }

  context "round and two completed" do
    before do
      (1..2).each do |round|
        Team::REGIONS.each do |region|
          Game.round_for(round, region).each do |game|
            while game.score_one.nil? || game.score_one == game.score_two
              game.update_attributes(score_one: rand(100), score_two: rand(100))
            end
          end
        end
      end
    end

    describe "#generate_cached_opts" do
      it "gathers all games in slot_bit order"
      it "gathers all brackets and caches the associated picks"
      it "gathers all team objects in a hash"
    end

    describe "#generate_all_slot_bits" do
      it "iterates on bits of remaining games"
      it "keeps already played games mask constant"

      context "with a block" do
        it "is nil"
        it "yeilds individual slot_bits"
      end

      context "without a block" do
        it "is all collected slot bits"
      end
    end

    describe "#generate_outcome" do
      context "with cached options passed in" do
        it "uses the games from options"
        it "uses the passed in brackets"
        it "uses the passed in teams"
      end

      context "with no cached options passed in" do
        it "gathers all games in slot_bit order"
        it "gathers all brackets"
        it "gathers all teams"
      end

      it "generates all possible games given the slot bits"
    end

    describe "#update_brackets_best_possible" do

    end
  end
end
