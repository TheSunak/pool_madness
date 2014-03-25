# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name
user.add_role :admin


[
    {:name=>"Florida", :seed=>1, :score_team_id=>62, :region=>"South"},
    {:name=>"UCLA", :seed=>4, :score_team_id=>113, :region=>"South"},
    {:name=>"Dayton", :seed=>11, :score_team_id=>49, :region=>"South"},
    {:name=>"Stanford", :seed=>10, :score_team_id=>85, :region=>"South"},

    {:name=>"Virginia", :seed=>1, :score_team_id=>105, :region=>"East"},
    {:name=>"Michigan St", :seed=>4, :score_team_id=>64, :region=>"East"},
    {:name=>"Iowa St", :seed=>3, :score_team_id=>111, :region=>"East"},
    {:name=>"Connecticut", :seed=>7, :score_team_id=>66, :region=>"East"},

    {:name=>"Arizona", :seed=>1, :score_team_id=>88, :region=>"West"},
    {:name=>"San Diego St", :seed=>4, :score_team_id=>80, :region=>"West"},
    {:name=>"Baylor", :seed=>6, :score_team_id=>84, :region=>"West"},
    {:name=>"Wisconsin", :seed=>2, :score_team_id=>52, :region=>"West"},

    {:name=>"Kentucky", :seed=>8, :score_team_id=>109, :region=>"Midwest"},
    {:name=>"Louisville", :seed=>4, :score_team_id=>78, :region=>"Midwest"},
    {:name=>"Tennessee", :seed=>11, :score_team_id=>39, :region=>"Midwest"},
    {:name=>"Michigan", :seed=>2, :score_team_id=>68, :region=>"Midwest"}
].each do |team_hash|
  Team.create team_hash
end

#Sweet 16
Team.all.each_slice(2) do |one, two|
  Game.create :team_one => one, :team_two => two
end

#Great 8
great8 = []
Game.all.each_slice(2) do |one, two|
  great8 << Game.create(:game_one => one, :game_two => two)
end

#Final 4
final4 = []
great8.each_slice(2) do |one, two|
  final4 << Game.create(:game_one => one, :game_two => two)
end

#Championship
Game.create :game_one => final4.first, :game_two => final4.last
