class SearchController < ApplicationController
  def index
    if params[:query]
      @players = Player.find(:all, :conditions => ['name LIKE ?', "%#{params[:query]}%"])
      @clubs = Club.find(:all, :conditions => ['name LIKE ?', "%#{params[:query]}%"])
    end
  end
end
