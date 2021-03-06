class BracketsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource :pool, only: [:index, :create]
  load_and_authorize_resource :bracket, through: :pool, only: [:create]
  load_and_authorize_resource :bracket, except: [:index, :create]

  before_action :load_pool, except: [:index, :create]
  before_action :set_jskit_payload, only: [:edit]

  layout "bracket", except: [:index]

  def index
    if @pool.started?
      @brackets = @pool.brackets.to_a
      @brackets.sort_by! { |x| [100_000 - [x.best_possible, 4].min, x.points, x.possible_points] }
      @brackets.reverse!
    else
      @brackets = @pool.brackets.where(user_id: current_user).to_a
      @brackets.sort_by! { |x| [[:ok, :unpaid, :incomplete].index(x.status), x.name] }
      @unpaid_brackets = @brackets.select {|b| b.status == :unpaid}
    end
  end

  def show
  end

  def create
    if @bracket.save
      redirect_to edit_bracket_path(@bracket)
    else
      redirect_to pool_brackets_path(@pool), alert: "Problem creating a new bracket. Please try again."
    end
  end

  def update
    if @bracket.update(update_params)
      redirect_to pool_brackets_path(@pool), notice: "Bracket Saved"
    else
      flash.now[:error] = "Problem saving bracket. Please try again"
      render :edit
    end
  end

  def destroy
    @bracket.destroy
    redirect_to pool_brackets_path(@pool), notice: "Bracket Destroyed"
  end

  private

  def load_pool
    @pool = @bracket.pool
  end

  def update_params
    params.require(:bracket).permit(:tie_breaker, :name, :points, :possible_points)
  end

  def set_jskit_payload
    game_transitions = {}
    game_to_pick = {}
    champ_game_id = @bracket.tournament.championship.id

    @bracket.tournament.games.all.each do |g|
      game_to_pick[g.id] = @bracket.picks.find_by(game_id: g.id).id
      game_transitions[g.id] = [g.next_game.id, g.next_slot] unless g.next_game.blank?
    end

    set_action_payload(game_transitions, game_to_pick, champ_game_id)
  end
end
