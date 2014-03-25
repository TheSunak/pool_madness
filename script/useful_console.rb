  def controller
    @controller ||= ActionController::Base.new
  end

  def expire_action(action)
    controller.send(:expire_action, action)
  end

    expire_action "/brackets/#{bracket.id}"
    expire_action "/admin/brackets"
    expire_action "/public/brackets"
    expire_action "/public/brackets/#{bracket.user.id}"

    Rails.cache.delete("sorted_four_#{bracket.id}")

        expire_action "/admin/games"
    expire_action "/public/games"

    Bracket.all.each do |bracket|
      expire_action "/brackets/#{bracket.id}"
      expire_action "/public/brackets/#{bracket.user.id}"
    end

    if Pool.started?
      expire_action "/public/brackets" if bracket.points_changed? || bracket.possible_points_changed?
    else
      expire_action "/brackets/#{bracket.id}"
      expire_action "/admin/brackets"
      expire_action "/public/brackets/#{bracket.user.id}"
      Rails.cache.delete("sorted_four_#{bracket.id}")
    end

#Grabbing sweet-16 teams and games
  teams = []
  Team::REGIONS.each do |region|
    Game.round_for(3, region).each do |game|
      teams << game.first_team
      teams << game.second_team
    end
  end

  team_hashes = teams.collect do |team|
    team_hash = {}
    [:name, :seed, :score_team_id, :region].each do |attr|
      team_hash[attr] = team.send(attr)
    end
    team_hash
  end

#  => [{:name=>"Florida", :seed=>1, :score_team_id=>62, :region=>"South"}, {:name=>"UCLA", :seed=>4, :score_team_id=>113, :region=>"South"}, {:name=>"Dayton", :seed=>11, :score_team_id=>49, :region=>"South"}, {:name=>"Stanford", :seed=>10, :score_team_id=>85, :region=>"South"}, {:name=>"Virginia", :seed=>1, :score_team_id=>105, :region=>"East"}, {:name=>"Michigan St", :seed=>4, :score_team_id=>64, :region=>"East"}, {:name=>"Iowa St", :seed=>3, :score_team_id=>111, :region=>"East"}, {:name=>"Connecticut", :seed=>7, :score_team_id=>66, :region=>"East"}, {:name=>"Arizona", :seed=>1, :score_team_id=>88, :region=>"West"}, {:name=>"San Diego St", :seed=>4, :score_team_id=>80, :region=>"West"}, {:name=>"Baylor", :seed=>6, :score_team_id=>84, :region=>"West"}, {:name=>"Wisconsin", :seed=>2, :score_team_id=>52, :region=>"West"}, {:name=>"Kentucky", :seed=>8, :score_team_id=>109, :region=>"Midwest"}, {:name=>"Louisville", :seed=>4, :score_team_id=>78, :region=>"Midwest"}, {:name=>"Tennessee", :seed=>11, :score_team_id=>39, :region=>"Midwest"}, {:name=>"Michigan", :seed=>2, :score_team_id=>68, :region=>"Midwest"}]
