# frozen_string_literal: true

module OpenAIServices
  class CreateRun < ::ServiceBase
    attr_reader :access_token, :client, :thread_id, :assistant_id, :response, :run_id

    def initialize(thread_id:, assistant_id:)
      super
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
      @thread_id = thread_id
      @assistant_id = assistant_id
    end

    def call
      validate
      return self unless success?

      create_run
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def validate
      add_error 'Thread ID is blank' if @thread_id.blank?
      add_error 'Assistant ID is blank' if @assistant_id.blank?
    end

    def create_run
      @response = @client.runs.create(
        thread_id: @thread_id,
        parameters: {
          assistant_id: @assistant_id,
        }
      )
    end

    def handle_response
      @run_id = @response.dig("id")
    end
  end
end
