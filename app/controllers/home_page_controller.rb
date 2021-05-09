class HomePageController < ApplicationController
  def show
    @sentence = "chickens like to jump"
    @guess = params[:guess]
    @opened_letters = []
    if @guess.present?
      if @sentence.include? @guess
        @opened_letters << @guess       
      end
    end
  end
end
