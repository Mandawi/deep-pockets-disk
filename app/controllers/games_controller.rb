require_dependency './lib/games_utils'
require 'tts'

class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy start guess]
  before_action :set_game_room, only: [:show, :update, :guess]
  before_action :set_waiting_room, only: [:show, :update]
  before_action :require_login
  skip_before_action :verify_authenticity_token
  include ActionView::RecordIdentifier
  include ActionView::Helpers::NumberHelper

  # GET /games or /games.json
  def index
    @games = Game.all
    @game = Game.new
  end

  # GET /games/1 or /games/1.json
  def show
    # TODO: Update to include:
    # - Rounds
    # - Players
    # - Turns
    # - Track money
    @disk_content = GamesUtils.get_disk_content
    if @round.present? and @round.over?
      next_round = @round.next
      
      if next_round.present?
        @game.update(current_round_id: next_round.id)
        update_game_room
        @current_user = current_user
        Turbo::StreamsChannel.broadcast_replace_to(
          [@game, :started], 
          target: "#{dom_id(@game)}_room_chooser", 
          partial: "games/room_chooser", 
          locals: {
            game: @game, 
            sentence: @sentence, 
            round: @round,
            player: @player,
            topic: @topic,
            opened_letters: @opened_letters,
            players_money: @players_money,
          }
        )
      else
        redirect_to games_url
      end
    # elsif @guess.present?
    #   if @sentence.include? @guess and not @opened_letters.include? @guess
    #     @round_player.update(player_money: @round_player.player_money + @sentence.count(@guess))
    #     @round.update(opened_letters: @opened_letters << @guess)  
    #   else
    #     next_player = @game.next_player(@player)
    #     @round.update(current_player_id: next_player.id)
    #   end

    #   if @sentence.chars.uniq.sort == @round.opened_letters.sort
    #     @round.update(over: true)
    #   end
    #   update_game_room  
    #   Turbo::StreamsChannel.broadcast_replace_to(
    #     [@game, :started], 
    #     target: "#{dom_id(@game)}_room_chooser", 
    #     partial: "games/room_chooser", 
    #     locals: {
    #       game: @game, 
    #       guess: @guess,
    #       sentence: @sentence, 
    #       round: @round,
    #       player: @player,
    #       topic: @topic,
    #       opened_letters: @opened_letters,
    #       players_money: @players_money,
    #       current_user_id: current_user.id
    #     }
    #   )
    end
  end

  # POST /games/1/guess
  def guess
    if current_user.id != @player.id
      redirect_to @game, alert: "It's not your turn yet!"
    else
      if @full_guess.present?
        "#{@full_guess}".play('ar')
        if @sentence == @full_guess
          'جوابْ صحيحْ'.play('ar')
          @round_player.update(player_money: @round_player.player_money + 1000)
          @round.update(opened_letters: (@opened_letters + @full_guess.gsub(/\s+/, "").split("")).uniq)  
          update_game_room  
          Turbo::StreamsChannel.broadcast_replace_to(
            [@game, :started], 
            target: "#{dom_id(@game)}_room_chooser", 
            partial: "games/room_chooser", 
            locals: {
              game: @game, 
              guess: @guess,
              sentence: @sentence, 
              round: @round,
              player: @player,
              topic: @topic,
              opened_letters: @opened_letters,
              players_money: @players_money,
            }
          )
          "مبروكْ الفْوْزْ يا  #{helpers.get_username(User.find(@round_player.user_id).email)}".play('ar')
          "رَصْيْدَكْ الْكْامِلْ هْوَ #{@round_player.player_money} دولارْ".play('ar')
        else
          'جوابْ غلطْ بغلطْ'.play('ar')
          next_player = @game.next_player(@player)
          @round.update(current_player_id: next_player.id)
          "صارْ دْوْرْ #{helpers.get_username(next_player.email)}".play('ar')
        end
      else
        if @spin_result == -1
          @round_player.update(player_money: 0)
          'راحْ الرصيدْ معَ الأسفْ'.play('ar')
          next_player = @game.next_player(@player)
          "صارْ دْوْرْ #{helpers.get_username(next_player.email)}".play('ar')
          @round.update(current_player_id: next_player.id)
        elsif @sentence.include? @guess and not @opened_letters.include? @guess
          "#{@spin_result} دولارْ".play('ar')
          "حرفُ الْ #{@guess} ".play('ar')
          'جوابْ صحيحْ'.play('ar')
          @round.update(opened_letters: @opened_letters << @guess)
          update_game_room  
          Turbo::StreamsChannel.broadcast_replace_to(
            [@game, :started], 
            target: "#{dom_id(@game)}_room_chooser", 
            partial: "games/room_chooser", 
            locals: {
              game: @game, 
              guess: @guess,
              sentence: @sentence, 
              round: @round,
              player: @player,
              topic: @topic,
              opened_letters: @opened_letters,
              players_money: @players_money,
            }
          )
          Turbo::StreamsChannel.broadcast_replace_later_to(
            [@game, :started], 
            target: "#{dom_id(@game)}_room_chooser", 
            partial: "games/room_chooser", 
            locals: {
              game: @game, 
              guess: @guess,
              sentence: @sentence, 
              round: @round,
              player: @player,
              topic: @topic,
              opened_letters: @opened_letters,
              players_money: @players_money,
            }
          )
          "موجود منهُ #{@sentence.count(@guess)}".play('ar')
          @round_player.update(player_money: @round_player.player_money + (@sentence.count(@guess) * @spin_result))
          "رَصْيْدَكْ الْكْامِلْ هْوَ #{@round_player.player_money} دولارْ".play('ar')
        else
          "#{@spin_result} دولارْ".play('ar')
          "حرفْ ال #{@guess} ".play('ar')
          'جوابْ غلطْ '.play('ar')
          next_player = @game.next_player(@player)
          @round.update(current_player_id: next_player.id)
          "صارْ دْوْرْ #{helpers.get_username(next_player.email)}".play('ar')
        end
      end

      if @sentence.chars.uniq.sort.length == @round.opened_letters.sort.length
        @round.update(over: true)
        "مبروكْ الفْوْزْ يا  #{helpers.get_username(User.find(@round_player.user_id).email)}".play('ar')
      end
      update_game_room  
      Turbo::StreamsChannel.broadcast_replace_to(
        [@game, :started], 
        target: "#{dom_id(@game)}_room_chooser", 
        partial: "games/room_chooser", 
        locals: {
          game: @game, 
          guess: @guess,
          sentence: @sentence, 
          round: @round,
          player: @player,
          topic: @topic,
          opened_letters: @opened_letters,
          players_money: @players_money,
        }
      )
      redirect_to @game
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
    redirect_to games_path
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
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
    redirect_to @game    
  end

  # PATCH /games/1
  def start
    @game.update( started: true, 
                  current_round_id: @game.rounds.first.id)
    redirect_to @game
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.rounds.each do |round|
      round.round_players.delete_all
    end
    @game.rounds.delete_all
    @game.game_players.delete_all
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
      session[:current_user_id] = current_user.id
    end

    def set_game_room
      if @game.started?
        @round = Round.find(@game.current_round_id)
        @player = User.find(@round.current_player_id)
        @round_player = @round.round_players.where(user_id: @player.id).first
        @sentence = @round.sentence
        @topic = @round.topic
        @guess = params[:guess]
        @full_guess = params[:full_guess]
        @spin_result = params[:spin_result].to_i
        @opened_letters = @round.opened_letters
        @players_money = @round.round_players.map{ |round_player| "#{ helpers.get_username(User.find(round_player.user_id).email)}: #{ number_to_currency(round_player.player_money, precision: 0) }" }
      end
    end

    def update_game_room
      @round = Round.find(@game.current_round_id)
      @player = User.find(@round.current_player_id)
      @round_player = @round.round_players.where(user_id: @player.id).first
      @sentence = @round.sentence
      @topic = @round.topic
      @guess = params[:guess]
      @full_guess = params[:full_guess]
      @spin_result = params[:spin_result].to_i
      @opened_letters = @round.opened_letters
      @players_money = @round.round_players.map{ |round_player| "#{ helpers.get_username(User.find(round_player.user_id).email)}: #{ number_to_currency(round_player.player_money, precision: 0) }" }
    end

    def set_waiting_room
      if not @game.started?
        @game_players = @game.game_players
        if not @game.users.include? current_user and not @game.game_players.empty?
          GamesUtils.create_game_player(@game, current_user, @game.game_players.last.player_order + 1)
        elsif not @game.users.include? current_user
          GamesUtils.create_game_player(@game, current_user, 0)
        end
        @user = helpers.get_username(current_user.email)
      end
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params.fetch(:game, {})
    end
end
