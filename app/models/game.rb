class Game < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :team_one, :class_name => Team
  belongs_to :team_two, :class_name => Team
  belongs_to :game_one, :class_name => Game
  belongs_to :game_two, :class_name => Game

  attr_accessible :team_one, :team_two, :game_one, :game_two, :score_one, :score_two

  #TODO: belongs in a sweeper
  after_update do |game|
    Rails.cache.delete('views/all_brackets')
    Bracket.select('id').all.each { |b| Rails.cache.delete("views/bracket-show-#{b.id}") }
  end

  def first_team
    self.team_one || self.game_one.winner
  end

  def second_team
    self.team_two || self.game_two.winner
  end

  def winner
    return nil if score_one.nil? || score_two.nil?
    score_one > score_two ? first_team : second_team
  end

  def next_game
    Game.where(:game_one_id => self.id).first || Game.where(:game_two_id => self.id).first
  end

  #returns 1, 2 or nil
  def next_slot
    [0, next_game.game_one_id, next_game.game_two_id].index(self.id)
  end

  def round
    round = 4 #championship
    n = self.next_game
    while n.present?
      round -= 1
      n = n.next_game
    end
    round
  end

  def self.championship
    game = Game.first
    game = game.next_game while game.next_game.present?
    game
  end

  def self.round_for(round_number, region=nil)
    case round_number
      when 3
        [Game.championship.game_one, Game.championship.game_two]
      when 4
        [Game.championship]
      when 1
        sort_order = [8, 5, 7, 6]
        teams = Team.where(:seed => sort_order).all
        Game.where(:team_one_id => teams.collect(&:id)).all.sort_by {|x| sort_order.index(x.first_team.seed)}
      when 2
        sort_order = [1, 4, 2, 3]
        teams = Team.where(:seed => sort_order).all
        Game.where(:team_one_id => teams.collect(&:id)).all.sort_by {|x| sort_order.index(x.first_team.seed)}
    end
  end
end
