# frozen_string_literal: true

class BotMessageSenderWorker
  include Sidekiq::Worker

  def initialize(messenger_service: MessengerService::Client.new)
    @messenger_service = messenger_service
  end

  def perform(user_id, message)
    puts "send_bot_message: #{user_id} #{message}"
    # sentences = message.split(SENTENCE_REGEX)
    #
    # sentences.each do |sentence|
    #   @messenger_service.send_action(user_id, "typing_on")
    #   duration = get_typing_duration(sentence, DEFAULT_TYPING_SPEED)
    #   sleep(duration / 1000.0)
    #   @messenger_service.send_message(user_id, sentence)
    #   puts "Sent: #{sentence}"
    # end
    #
    # puts "All messages sent"
  end

  # private def get_typing_duration(text, typing_speed)
  #   characters = text.length
  #   characters_per_second = typing_speed / 60.0
  #   duration_in_seconds = characters / characters_per_second
  #   duration_in_milliseconds = duration_in_seconds * 1000
  #
  #   # Multiply the duration by the random factor
  #   random_factor = 0.8 + rand * (1.2 - 0.8)
  #   adjusted_duration = duration_in_milliseconds * random_factor
  #
  #   adjusted_duration
  # end
end
