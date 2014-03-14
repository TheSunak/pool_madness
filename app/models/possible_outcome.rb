class PossibleOutcome < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :possible_games

  def championship
    possible_game = self.possible_games.first
    possible_game = possible_game.next_game while possible_game.next_game.present?
    possible_game
  end

  def round_for(round_number, region=nil)
    case round_number
      when 3
        [self.championship.game_one, self.championship.game_two]
      when 4
        [self.championship]
      when 1
        sort_order = [8, 5, 7, 6]
        teams = Team.where(:seed => sort_order).all
        game_ids = Game.where(:team_one_id => teams.collect(&:id)).select(&:id).all.collect(&:id)
        self.possible_games.where(:game_id => game_ids).sort_by {|x| sort_order.index(x.first_team.seed)}
      when 2
        sort_order = [1, 4, 2, 3]
        teams = Team.where(:seed => sort_order).all
        game_ids = Game.where(:team_one_id => teams.collect(&:id)).select(&:id).all.collect(&:id)
        self.possible_games.where(:game_id => game_ids).sort_by {|x| sort_order.index(x.first_team.seed)}
    end
  end

  def self.generate_outcome(slot_bits)
    Game.all.each do |game|
      
    end
  end

end
