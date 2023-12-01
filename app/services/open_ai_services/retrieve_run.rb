# frozen_string_literal: true

module OpenAIServices
  class RetrieveRun < ::ServiceBase
    attr_reader :client, :thread_id, :run_id, :response, :status

    # Initializes a new instance of the RetrieveRun service.
    #
    # This method sets up the necessary attributes for interacting with the OpenAI API,
    # including configuring the OpenAI client with the API key, and initializing thread_id
    # and run_id instance variables. After the service call (using the `call` method),
    # the `:status` is extracted from the response and set as an instance variable.
    #
    # @param thread_id [String] The unique identifier of the thread associated with the run.
    # @param run_id [String] The identifier of the specific run to be retrieved.
    #
    # @example
    #   retrieve_run_service = OpenAIServices::RetrieveRun.new(thread_id: "12345", run_id: "67890")
    #   retrieve_run_service.call
    #   puts retrieve_run_service.status
    #
    # @note
    #   This method requires the OPENAI_API_KEY environment variable to be set with a valid OpenAI API key.
    #   The `thread_id` and `run_id` parameters are required and cannot be blank. The `:status` is
    #   available only after successfully executing the `call` method.
    #
    # @raise [ArgumentError]
    #   If the `thread_id` or `run_id` is not provided or is blank, an ArgumentError will be raised.
    #
    # @return [OpenAIServices::RetrieveRun]
    #   Returns an instance of RetrieveRun. This instance needs to be used with the `call` method to
    #   perform the actual action and obtain the `:status`.
    def initialize(thread_id:, run_id:)
      super
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
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
