# frozen_string_literal: true

module OpenAIServices
  class CreateThread < ::ServiceBase
    attr_reader :access_token, :client, :response, :thread_id

    def initialize
      super
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
    end

    def call
      create_thread
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def create_thread
      @response = @client.threads.create
    end

    def handle_response
      @thread_id = @response.dig("id")
    end
  end
end
