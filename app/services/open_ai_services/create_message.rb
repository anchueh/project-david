# frozen_string_literal: true

module OpenAIServices
  class CreateMessage < ::ServiceBase
    attr_reader :client, :thread_id, :message, :response, :message_id

    # Initializes a new instance of the CreateMessage service.
    #
    # This method sets up the necessary attributes for interacting with the OpenAI API,
    # including configuring the OpenAI client with the API key and initializing thread_id
    # and message instance variables. After the service call (using the `call` method),
    # the `:message_id` is extracted from the response and set as an instance variable.
    #
    # @param thread_id [String] The unique identifier of the thread for which the message is being created.
    # @param message [String] The content of the message to be sent.
    #
    # @example
    #   create_message_service = OpenAIServices::CreateMessage.new(thread_id: "12345", message: "Hello, OpenAI!")
    #   create_message_service.call
    #   puts create_message_service.message_id
    #
    # @note
    #   This method requires the OPENAI_API_KEY environment variable to be set with a valid OpenAI API key.
    #   The `thread_id` and `message` parameters are required and cannot be blank. The `:message_id` is
    #   available only after successfully executing the `call` method.
    #
    # @raise [ArgumentError]
    #   If the `thread_id` or `message` is not provided or is blank, an ArgumentError will be raised.
    #
    # @return [OpenAIServices::CreateMessage]
    #   Returns an instance of CreateMessage. This instance needs to be used with the `call` method to
    #   perform the actual action and obtain the `:message_id`.
    def initialize(thread_id:, message:)
      super
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
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
      add_error I18n.t("open_ai_services.thread_id_is_blank") if @thread_id.blank?
      add_error I18n.t("open_ai_services.message_is_blank") if @message.blank?
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
