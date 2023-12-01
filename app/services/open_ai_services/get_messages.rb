# frozen_string_literal: true

module OpenAIServices
  class GetMessages < ::ServiceBase
    attr_reader :access_token, :client, :thread_id, :response, :data

    def initialize(thread_id:)
      super
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
      @thread_id = thread_id
    end

    def call
      validate
      return self unless success?

      get_messages
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def validate
      add_error 'Thread ID is blank' if @thread_id.blank?
    end

    def get_messages
      @response = @client.messages.list(thread_id: @thread_id)
    end

    def handle_response
      @data = @response.dig("data")
    end
  end
end
