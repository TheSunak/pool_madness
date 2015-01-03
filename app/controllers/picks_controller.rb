class PicksController < ApplicationController
  load_and_authorize_resource

  cache_sweeper :pick_sweeper

  def update
    @pick.update_attributes(params[:pick])
    render nothing: true
  end
end
