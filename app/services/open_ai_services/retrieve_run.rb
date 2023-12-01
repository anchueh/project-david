# frozen_string_literal: true

module OpenAIServices
  class RetrieveRun < ::ServiceBase
    attr_reader :access_token, :client, :thread_id, :run_id, :response, :status

    def initialize(thread_id:, run_id:)
      super()
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
      @thread_id = thread_id
      @run_id = run_id
    end

    def call
      validate
      return self unless success?

      retrieve_run
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def validate
      add_error 'Thread ID is blank' if @thread_id.blank?
      add_error 'Run ID is blank' if @run_id.blank?
    end

    def retrieve_run
      @response = @client.runs.retrieve(thread_id: @thread_id, id: @run_id)
    end

    def handle_response
      @status = @response.dig("status")
    end
  end
end
