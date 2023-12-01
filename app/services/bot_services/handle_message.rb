# frozen_string_literal: true

module BotServices
  class HandleMessage < ::ServiceBase
    attr_reader :message, :user_id

    def initialize(message:, user_id:)
      super()
      @message = message
      @user_id = user_id
    end

    def call
      validate
      return self unless success?

      message_init_service = initialize_message
      return self unless message_init_service.success?

      watch_and_handle_run(message_init_service)
      self
    rescue StandardError => e
      add_error e.message
    end

    private

    def validate
      add_error 'Message is blank' if @message.blank?
      add_error 'User ID is blank' if @user_id.blank?
    end

    def initialize_message
      message_init_service = HandleMessageInitialization.new(message: @message, user_id: @user_id)
      message_init_service.call
      propagate_errors(message_init_service)
      message_init_service
    end

    def watch_and_handle_run(message_init_service)
      run_watcher_service = HandleRunWatcher.new(
        thread_id: message_init_service.thread_id,
        run_id: message_init_service.run_id,
        user_id: @user_id
      )
      run_watcher_service.call
      propagate_errors(run_watcher_service)
    end

    def propagate_errors(service)
      service.errors.each { |error| add_error(error) } if service.error?
    end
  end
end

