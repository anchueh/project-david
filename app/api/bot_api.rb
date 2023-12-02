# frozen_string_literal: true
class BotAPI < ApplicationAPI
  prefix :bot
  format :json

  page_ids = ENV["PAGE_IDS"].split(",")

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
      params["entry"].each do |entry|
        entry["messaging"].each do |messaging_event|
          sender_id = messaging_event.dig("sender", "id")
          message = messaging_event.dig("message", "text")
          reaction = messaging_event.dig("reaction")
          is_echo = messaging_event.dig("message", "is_echo")
          if !is_echo && !page_ids.include?(sender_id)
            if message
              handle_message_service = BotServices::HandleMessage.new(user_id: sender_id, message: message)
              handle_message_service.call
            elsif reaction
              # handle reaction
            end
          end
        end
      end

      status 200
    end
  end
end