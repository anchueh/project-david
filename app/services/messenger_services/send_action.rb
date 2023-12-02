# frozen_string_literal: true

module MessengerServices
  class SendAction < ::ServiceBase
    attr_reader :user_id, :action, :page_access_token, :uri, :response

    def initialize(user_id:, action:)
      super
      @user_id = user_id
      @action = action
      @page_access_token = ENV['PAGE_ACCESS_TOKEN']
      @uri = URI.parse("https://graph.facebook.com/v16.0/me/messages?access_token=#{@page_access_token}")
    end

    def call
      validate
      return self unless success?

      send_action
      handle_response
      self
    end

    def validate
      add_error I18n.t('messenger_services.user_id_is_blank') if @user_id.blank?
      add_error I18n.t('messenger_services.action_is_blank') if @action.blank?
    end

    def send_action
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(@uri.request_uri, 'Content-Type' => 'application/json')
      request.body = request_body.to_json
      @response = http.request(request)
    rescue StandardError => e
      add_error e.message
    end

    def request_body
      {
        recipient: {
          id: @user_id
        },
        sender_action: @action
      }
    end

    def handle_response
      unless @response.is_a?(Net::HTTPSuccess)
        add_error I18n.t('messenger_services.send_action_failed')
      end
    end
  end
end
