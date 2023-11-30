# frozen_string_literal: true

class BotMessageSenderWorker
  include Sidekiq::Worker

  SENTENCE_REGEX = /(?<!\w\.\w.)(?<![A-Z][a.z]\.)(?<=\.|\?|\!|\n|(?<=\s|^)(?<!\s|^)(?<!\s|^))\s*/.freeze
  DEFAULT_TYPING_SPEED = 400 # characters per minute

  def initialize(user_id:, message:)
    @user_id = user_id
    @message = message
  end

  def perform(user_id, message)
    puts "send_bot_message: #{user_id} #{message}"
    sentences = message.split(SENTENCE_REGEX)

    send_action_service = MessengerServices::SendAction.new(user_id: user_id, action: "typing_on")

    sentences.each do |sentence|
      send_action_service.call
      duration = get_typing_duration(sentence, DEFAULT_TYPING_SPEED)
      sleep(duration / 1000.0)
      send_message_service = MessengerServices::SendMessage.new(user_id: user_id, message: sentence)
      send_message_service.call
      puts "Sent: #{sentence}"
    end

    puts "All messages sent"
  end

  private def get_typing_duration(text, typing_speed)
    characters = text.length
    characters_per_second = typing_speed / 60.0
    duration_in_seconds = characters / characters_per_second
    duration_in_milliseconds = duration_in_seconds * 1000

    random_factor = 0.8 + rand * (1.2 - 0.8)
    adjusted_duration = duration_in_milliseconds * random_factor

    adjusted_duration
  end
end
