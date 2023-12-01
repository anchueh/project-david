# frozen_string_literal: true

module OpenAIServices
  class CreateThread < ::ServiceBase
    attr_reader :client, :response, :thread_id

    # Initializes a new instance of the CreateThread service.
    #
    # This method sets up the necessary attributes for interacting with the OpenAI API,
    # specifically for thread creation. It configures the OpenAI client with the API key.
    # After the service call (using the `call` method), the `:thread_id` is extracted from
    # the response and set as an instance variable.
    #
    # @example
    #   create_thread_service = OpenAIServices::CreateThread.new
    #   create_thread_service.call
    #   puts create_thread_service.thread_id
    #
    # @note
    #   This method requires the OPENAI_API_KEY environment variable to be set with a valid
    #   OpenAI API key. The `:thread_id` is available only after successfully executing the
    #   `call` method.
    #
    # @raise [StandardError]
    #   Catches and handles any StandardError that might occur during the execution of the
    #   `call` method, adding the error message to the service's errors.
    #
    # @return [OpenAIServices::CreateThread]
    #   Returns an instance of CreateThread. This instance needs to be used with the `call`
    #   method to perform the actual action of thread creation and obtain the `:thread_id`.
    def initialize
      super
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
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
