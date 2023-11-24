# frozen_string_literal: true

module BotService
  class Client
    def initialize(
      open_ai_service: OpenAIService::DavidClient.new,
      messenger_service: MessengerService::Client.new
    )
      @open_ai_service = open_ai_service
      @messenger_service = messenger_service
    end

    def send_message(message)
      response = @open_ai_service.get_response(message)
      @messenger_service.send_message("6034297423330611", response)
    end
  end
end
