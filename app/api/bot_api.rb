# frozen_string_literal: true
class BotAPI < ApplicationAPI
  prefix :bot
  format :json

  resource :hello do
    get do
      params do
        requires :message, type: String
      end
      bot_service = BotService::Client.new
      bot_service.send_message(params[:message])
    end
  end

  resource :webhook do
    get do
      params do
        requires :message, type: String
      end
      user_id = ENV["RECIPIENT_IDS"].split(",").first
      bot_service = BotService::Client.new
      bot_service.handle_message(params[:message], user_id)
    end
  end

end

