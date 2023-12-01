# frozen_string_literal: true

module OpenAIServices
  class GetMessages < ::ServiceBase
    attr_reader :client, :thread_id, :response, :data

    # Initializes a new instance of the GetMessages service.
    #
    # This method sets up the necessary attributes for interacting with the OpenAI API,
    # including configuring the OpenAI client with the API key and initializing the thread_id
    # instance variable. After the service call (using the `call` method), the response
    # containing the messages is obtained, and the relevant data is extracted and set as
    # an instance variable.
    #
    # @param thread_id [String] The unique identifier of the thread for which messages are being retrieved.
    #
    # @example
    #   get_messages_service = OpenAIServices::GetMessages.new(thread_id: "12345")
    #   get_messages_service.call
    #   messages_data = get_messages_service.data
    #
    # @note
    #   This method requires the OPENAI_API_KEY environment variable to be set with a valid OpenAI API key.
    #   The `thread_id` parameter is required and cannot be blank. The response data is available only after
    #   successfully executing the `call` method.
    #
    # @raise [ArgumentError]
    #   If the `thread_id` is not provided or is blank, an ArgumentError will be raised.
    #
    # @return [OpenAIServices::GetMessages]
    #   Returns an instance of GetMessages. This instance must be used with the `call` method to
    #   perform the actual action and access the retrieved messages through the `data` attribute.
    def initialize(thread_id:)
      super
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      @thread_id = thread_id
    end

    def call
      validate
      return self unless success?

      get_messages
      handle_response
      self
    rescue StandardError => e
      add_error e.message
    end

    def validate
      add_error 'Thread ID is blank' if @thread_id.blank?
    end

    def get_messages
      @response = @client.messages.list(thread_id: @thread_id)
    end

    def handle_response
      @data = @response.dig("data")
    end
  end
end
