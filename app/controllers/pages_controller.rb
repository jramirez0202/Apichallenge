class PagesController < ApplicationController
  def home
    @pokemon = Pokemon.all
  end
end
