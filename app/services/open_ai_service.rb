# frozen_string_literal: true

module OpenAIService
  require 'openai'

  class DavidClient
    def initialize
      @access_token = ENV["OPENAI_API_KEY"]
      @assistant_id = ENV["OPENAI_ASSISTANT_ID"]
      @client = OpenAI::Client.new(access_token: @access_token)
    end

    def get_response(prompt)
      response = @client.chat(
        parameters: {
          model: "gpt-4-1106-preview",
          messages: [
            {
              role: "user",
              content: prompt
            }
          ]
        },
      )
      puts @client.assistants.list
      response.dig("choices", 0, "message", "content")
    end

    def create_thread
      response = @client.threads.create(
        parameters: {
          display_name: "test"
        }
      )
      response.dig("id")
    end

    def retrieve_thread(id)
      @client.threads.retrieve(id: id)
    end

    def create_run(thread_id)
      response = @client.runs.create(
        thread_id: thread_id,
        parameters: {
          assistant_id: @assistant_id,
        }
      )
      response.dig("id")
    end

    def retrieve_run(thread_id, run_id)
      @client.runs.retrieve(thread_id: thread_id, id: run_id)
    end

    def get_messages(thread_id)
      @client.messages.list(thread_id: thread_id)
    end

  end
end
