class LeaderboardsController < ApplicationController
  PER_PAGE = 50

  def index
    @page = [params[:page].to_i, 1].max
    @total_pages = [(User.count.to_f / PER_PAGE).ceil, 1].max
    @page = [@page, @total_pages].min
    @ranked_users = User.ranked_leaderboard.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end
end
