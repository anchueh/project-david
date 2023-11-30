# frozen_string_literal: true

require "httparty"

module MessengerService
  class Client
    include HTTParty
    base_uri "https://graph.facebook.com/v16.0"

    def initialize
      @page_access_token = ENV["PAGE_ACCESS_TOKEN"]
    end

    def send_message(recipient_id, text)
      body = {
        recipient: {
          id: recipient_id
        },
        message: {
          text: text
        }
      }
      params = {
        access_token: @page_access_token
      }
      self.class.post(
        "/me/messages",
        query: params,
        body: body.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    def send_action(recipient_id, action)
      body = {
        recipient: {
          id: recipient_id
        },
        sender_action: action
      }
      self.class.post(
        "/me/messages",
        query: { access_token: @page_access_token },
        body: body.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end
  end
end
