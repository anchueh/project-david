# frozen_string_literal: true

module OpenAIServices
  class CreateRun < ::ServiceBase
    attr_reader :client, :thread_id, :assistant_id, :response, :run_id

    # Initializes a new instance of the CreateRun service.
    #
    # This method sets up the necessary attributes for interacting with the OpenAI API,
    # including configuring the OpenAI client with the API key and initializing thread_id
    # and assistant_id instance variables. After the service call (using the `call` method),
    # the `:run_id` is extracted from the response and set as an instance variable.
    #
    # @param thread_id [String] The unique identifier of the thread for which the run is being created.
    # @param assistant_id [String] The identifier of the assistant to be used for the run.
    #
    # @example
    #   create_run_service = OpenAIServices::CreateRun.new(thread_id: "12345", assistant_id: "assistant-123")
    #   create_run_service.call
    #   puts create_run_service.run_id
    #
    # @note
    #   This method requires the OPENAI_API_KEY environment variable to be set with a valid OpenAI API key.
    #   The `thread_id` and `assistant_id` parameters are required and cannot be blank. The `:run_id` is
    #   available only after successfully executing the `call` method.
    #
    # @raise [ArgumentError]
    #   If the `thread_id` or `assistant_id` is not provided or is blank, an ArgumentError will be raised.
    #
    # @return [OpenAIServices::CreateRun]
    #   Returns an instance of CreateRun. This instance needs to be used with the `call` method to
    #   perform the actual action and obtain the `:run_id`.
    def initialize(thread_id:, assistant_id:)
      super
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
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
