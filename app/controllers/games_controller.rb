require './lib/games_utils'
class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy join ]
  before_action :require_login

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # GET /games/1 or /games/1.json
  def show
    # TODO: Update to include:
    # - Rounds
    # - Players
    # - Turns
    # - Track money
    # - Add total money at end of round
    @sentence = "chickens like to jump"
    @guess = params[:guess]
    @opened_letters = @game.opened_letters
    @score = Score.where(game_id: @game.id, user_id: current_user.id).first
    if @guess.present?
      if @sentence.include? @guess and not @opened_letters.include? @guess
        newscore = @score.total + @sentence.count(@guess)
        @score.update(total: newscore)
        @game.update(opened_letters: @opened_letters << @guess)  
      end
    end
    @total = @score.total
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games/1/join
  def join
    # TODO: Update to include:
    # - Players
    # - Set player order
    # - Add one entry to GamePlayer
    # - Add entries for all rounds to RoundPlayer
    
    redirect_to @game
  end

  def wait
    # Wait here
  end

  # POST /games or /games.json
  def create
    # TODO: Update to include:
    # - Create all rounds
    # - Set round order
    # - Allow users to choose how many rounds
    @game = Game.create(game_params)
    3.each do |order|
      GameUtils.create_game_round(@game, order)
    end
    GameUtils.create_game_player(@game, current_user, 0)
    # redirect_to waiting_room
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: "Game was successfully updated." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.fetch(:game, {})
    end
end
