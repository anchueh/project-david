# frozen_string_literal: true

module OpenAIServices
  require 'openai'

  class CreateRun < ::ServiceBase
    attr_reader :access_token, :client, :response, :run_id

    def initialize
      super
      @access_token = ENV["OPENAI_API_KEY"]
      @client = OpenAI::Client.new(access_token: @access_token)
    end

    def call
      create_run
      handle_response
      self
    rescue StandardError => e
      add_error e.message
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
