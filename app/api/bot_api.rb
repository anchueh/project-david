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
        requires "hub.mode", type: String
        requires "hub.verify_token", type: String
        requires "hub.challenge", type: String
      end
      if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == ENV["VERIFY_TOKEN"]
        status 200
        body params["hub.challenge"]
      else
        status 403
      end
    end

    post do
      # print the formatted request body
      puts request.body
      user_id = ENV["RECIPIENT_IDS"].split(",").first
      bot_service = BotService::Client.new
      bot_service.handle_message(params[:message], user_id)
      status 200
    end
  end

end

