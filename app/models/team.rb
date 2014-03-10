class Team < ActiveRecord::Base
  attr_accessible :seed, :name, :score_team_id

  validates :name, :uniqueness => true, :length => {:maximum => 15}

  validates :seed,
            :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 },
            :uniqueness => true


  def first_game
    Game.find_by_team_one_id(self.id) || Game.find_by_team_two_id(self.id)
  end

  def still_playing?
    game = self.first_game
    while game.winner.present?
      return false if game.winner != self
      game = game.next_game
    end
    true
  end

  def eliminated?
    !still_playing?
  end
end
