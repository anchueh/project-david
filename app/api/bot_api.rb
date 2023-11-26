# frozen_string_literal: true
class BotAPI < ApplicationAPI
  prefix :bot
  format :json

  resource :hello do
    get do
      params do
        requires :message, type: String, allow_blank: false
      end
      bot_service = BotService::Client.new
      bot_service.send_message(params[:message])
    end
  end

  resource :webhook do
    get do
      content_type 'text/plain'
      env['api.format'] = :binary

      params do
        requires "hub.mode", type: String
        requires "hub.verify_token", type: String
        requires "hub.challenge", type: String
      end

      puts params["hub.verify_token"]
      puts ENV["VERIFY_TOKEN"]

      if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == ENV["VERIFY_TOKEN"]
        status 200
        puts params["hub.challenge"]
        # return hub.challenge without double quotes
        params["hub.challenge"].to_json.gsub(/\"/, "")
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

