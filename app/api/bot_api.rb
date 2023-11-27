# frozen_string_literal: true
class BotAPI < ApplicationAPI
  prefix :bot
  format :json

  page_ids = ENV["PAGE_IDS"].split(",")

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

      if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == ENV["VERIFY_TOKEN"]
        status 200
        params["hub.challenge"]
      else
        status 403
      end
    end

    post do
      content_type 'text/plain'
      env['api.format'] = :binary
      puts "request body: #{request.body.read}"

      if request.body.read
        request.body.rewind
        json = JSON.parse(request.body.read)

        if json["object"] == "page"
          json["entry"].each do |entry|
            entry["messaging"].each do |messaging_event|
              sender_id = messaging_event.dig("sender", "id")
              message = messaging_event.dig("message", "text")
              reaction = messaging_event.dig("reaction")
              is_echo = messaging_event.dig("message", "is_echo")
              if !is_echo && !page_ids.include?(sender_id)
                bot_service = BotService::Client.new
                if message
                  bot_service.handle_message(message, sender_id)
                elsif reaction
                  # handle reaction
                end
              end
            end
          end

          status 200
          "EVENT_RECEIVED"
        else
          status 404
        end
      end
    end
  end

end

