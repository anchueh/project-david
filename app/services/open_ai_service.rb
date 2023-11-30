# frozen_string_literal: true

module OpenAIService
  require 'openai'
  require 'httparty'

  class RunStatus
    QUEUED = "queued"
    IN_PROGRESS = "in_progress"
    REQUIRES_ACTION = "requires_action"
    CANCELLING = "cancelling"
    CANCELLED = "cancelled"
    FAILED = "failed"
    COMPLETED = "completed"
    EXPIRED = "expired"

    def self.running?(status)
      [QUEUED, IN_PROGRESS, REQUIRES_ACTION, CANCELLING].include?(status)
    end
  end

  class DavidClient
    def initialize
      @access_token = ENV["OPENAI_API_KEY"]
      @assistant_id = ENV["OPENAI_ASSISTANT_ID"]
      @client = OpenAI::Client.new(access_token: @access_token)
    end

    def create_thread
      response = @client.threads.create
      response.dig("id")
    end

    def create_run(thread_id)
      response = @client.runs.create(
        thread_id: thread_id,
        parameters: {
          assistant_id: @assistant_id,
        }
      )
      puts response
      response.dig("id")
    end

    def retrieve_run(thread_id, run_id)
      @client.runs.retrieve(thread_id: thread_id, id: run_id)
    end

    def get_messages(thread_id, order = "desc", limit = 20, after = nil)
      response = @client.messages.list(thread_id: thread_id)
      response.dig("data")
    end

    def create_message(thread_id, content)
      @client.messages.create(thread_id: thread_id, parameters: {
        role: "user",
        content: content
      })
    end

  end
end
