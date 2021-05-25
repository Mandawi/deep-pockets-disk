class GamesUtils
  ARABIC_CATEGORIZED_PHRASES_FILE_PATH = File.join(Rails.root, 'lib', 'assets', 'arabic-categorized-phrases.json')
  DISK_CONTENT = File.join(Rails.root, 'lib', 'assets', 'disk_content.json')
  def self.get_random_phrase_from_topic(topic)
    file = File.read(ARABIC_CATEGORIZED_PHRASES_FILE_PATH)
    return JSON.parse(file)[topic].sample
  end

  def self.create_game_player(game, user, player_order)
    game_player = game.game_players.create( user_id: user.id,
                              player_order: player_order)
    game.rounds.each do |round|
      round.round_players.create(user_id: user.id)
    end
    return game_player
  end

  def self.get_random_topic
    file = File.read(ARABIC_CATEGORIZED_PHRASES_FILE_PATH)
    return JSON.parse(file).keys.sample
  end

  def self.create_game_round(game, user, order, topic = nil)
    sentence, topic = get_sentence_and_topic(topic)
    round = Round.create( game_id: game.id,
                  topic: topic,
                  sentence: sentence,
                  order: order,
                  current_player_id: user.id)
    round.round_players.create(user_id: user.id)
  end

  def self.get_sentence_and_topic(topic = nil)
    if topic.nil?
      topic = self.get_random_topic
    end
    sentence = get_random_phrase_from_topic(topic)
    return sentence, topic
  end

  def self.get_disk_content
    file = File.read(DISK_CONTENT )
    return JSON.parse(file)
  end
end