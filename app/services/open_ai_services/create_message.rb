# frozen_string_literal: true

module OpenAIServices
  class CreateMessage < ::ServiceBase
    attr_reader :access_token, :client, :thread_id, :message, :response, :message_id

    def initialize(thread_id:, message:)
      super
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
      @thread_id = thread_id
      @message = message
    end

    def call
      validate
      return self unless success?

      create_message
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def validate
      add_error 'Thread ID is blank' if @thread_id.blank?
      add_error 'Message is blank' if @message.blank?
    end

    def create_message
      @response = @client.messages.create(thread_id: @thread_id, parameters: {
        role: "user",
        content: @message
      })
    end

    def handle_response
      @message_id = @response.dig("id")
    end
  end
end
