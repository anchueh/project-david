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
      add_error 'User ID is blank' if @user_id.blank?
      add_error 'Action is blank' if @action.blank?
    end

    def send_action
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(@uri.request_uri, 'Content-Type' => 'application/json')
      request.body = {
        recipient: {
          id: @user_id
        },
        sender_action: @action
      }.to_json
      @response = http.request(request)
      puts "response: #{@response.body}"
    rescue StandardError => e
      add_error e.message
    end

    def handle_response
      unless @response.is_a?(Net::HTTPSuccess)
        add_error "Failed to send action: #{@response.message}"
      end
    end
  end
end
