# frozen_string_literal: true
class BotAPI < ApplicationAPI
  prefix :bot
  format :json

  resource :hello do
    get do
      bot_service = BotService::Client.new
      bot_service.send_message("how are you")
    end
  end

end

