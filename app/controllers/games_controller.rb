require_dependency './lib/games_utils'
class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy start ]
  before_action :set_game_room, only: [:show]
  before_action :set_waiting_room, only: [:show]
  before_action :require_login

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # DEPRECATED SHOW
  # def show
  #   @sentence = "chickens like to jump"
    # @guess = params[:guess]
    # @opened_letters = @game.opened_letters
    # @score = Score.where(game_id: @game.id, user_id: current_user.id).first
    # if @guess.present?
    #   if @sentence.include? @guess and not @opened_letters.include? @guess
    #     newscore = @score.total + @sentence.count(@guess)
    #     @score.update(total: newscore)
    #     @game.update(opened_letters: @opened_letters << @guess)  
    #   end
    # end
    # @total = @score.total
  # end

  # GET /games/1 or /games/1.json
  def show
    # TODO: Update to include:
    # - Rounds
    # - Players
    # - Turns
    # - Track money
    # - Add total money at end of round
    if not @round.current_player_id.present?
      @round.update(current_player_id: @game.users.first.id)
    else
      update_game_room 
    end
    
    if @round.present? and @round.over?
      next_round = @round.next
      
      if next_round.present?
        @game.update(current_round_id: next_round.id)
        update_game_room
      else
        redirect_to games_url
      end
    elsif @guess.present?
      if @sentence.include? @guess and not @opened_letters.include? @guess
        @round_player.update(player_money: @round_player.player_money + @sentence.count(@guess))
        @round.update(opened_letters: @opened_letters << @guess)  
      else
        next_player = @game.next_player(@player)
        @round.update(current_player_id: next_player.id)
      end

      if @sentence.chars.uniq.sort == @round.opened_letters.sort
        @round.update(over: true)
      end
      update_game_room          
    end
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games or /games.json
  def create
    # TODO: Update to include:
    # - Allow users to choose how many rounds
    @game = Game.create(game_params)
    GamesUtils.create_game_player(@game, current_user, 0)
    (0..2).each do |order|
      GamesUtils.create_game_round(@game, current_user, order)
    end
    redirect_to @game
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

  def start
    @game.update( started: true, 
                  current_round_id: @game.rounds.first.id)
    redirect_to @game
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

    def set_game_room
      if @game.started?
        @round = Round.find(@game.current_round_id)
        @player = User.find(@round.current_player_id)
        @round_player = @round.round_players.where(user_id: @player.id).first
        @sentence = @round.sentence
        @topic = @round.topic
        @guess = params[:guess]
        @opened_letters = @round.opened_letters
        @players_money = @round.round_players.map{ |round_player| "#{ helpers.get_username(User.find(round_player.user_id).email)}: #{ round_player.player_money }" }
      end
    end

    def update_game_room
      @round = Round.find(@game.current_round_id)
      @player = User.find(@round.current_player_id)
      @round_player = @round.round_players.where(user_id: @player.id).first
      @sentence = @round.sentence
      @topic = @round.topic
      @guess = params[:guess]
      @opened_letters = @round.opened_letters
      @players_money = @round.round_players.map{ |round_player| "#{ helpers.get_username(User.find(round_player.user_id).email)}: #{ round_player.player_money }" }
    end

    def set_waiting_room
      if not @game.started?
        if not @game.users.include? current_user
          GamesUtils.create_game_player(@game, current_user, @game.game_players.last.player_order + 1)
        end
        @user = helpers.get_username(current_user.email)
        @players = @game.users.map { |user| helpers.get_username(user.email) }
      end
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.fetch(:game, {})
    end
end
