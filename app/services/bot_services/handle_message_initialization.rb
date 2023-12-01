# frozen_string_literal: true
#
module BotServices
  class HandleMessageInitialization < ::ServiceBase
    attr_reader :message, :user_id, :thread_id, :run_id

    def initialize(message:, user_id:)
      super
      @message = message
      @user_id = user_id
    end

    def call
      validate
      return self unless success?

      handle_initialization
      self
    rescue StandardError => e
      add_error e.message
    end

    private

    def validate
      add_error 'Message is blank' if @message.blank?
      add_error 'User ID is blank' if @user_id.blank?
    end

    def handle_initialization
      puts "Initializing message handling for: #{message} #{user_id}"
      send_mark_seen_action(user_id: user_id)

      thread = get_thread(user_id: user_id)
      @thread_id = thread[:thread_id]
      puts "thread_id: #{@thread_id}"

      create_message(thread_id: @thread_id, message: message)
      puts "message created"

      @run_id = create_run(thread_id: @thread_id, assistant_id: ENV['OPENAI_ASSISTANT_ID'])
      puts "run created #{@run_id}"
    end

    def get_thread(user_id:)
      user_thread = UserThread.find_by(user_id: user_id)
      unless user_thread
        create_thread_service = OpenAIServices::CreateThread.new
        create_thread_service.call
        thread_id = create_thread_service.thread_id
        user_thread = UserThread.create(user_id: user_id, thread_id: thread_id)
      end
      user_thread
    end

    def send_mark_seen_action(user_id:)
      send_mark_seen_action_service = MessengerServices::SendAction.new(user_id: user_id, action: "mark_seen")
      send_mark_seen_action_service.call
    end

    def create_message(thread_id:, message:)
      create_message_service = OpenAIServices::CreateMessage.new(thread_id: thread_id, message: message)
      create_message_service.call
      create_message_service.message_id
    end

    def create_run(thread_id:, assistant_id:)
      create_run_service = OpenAIServices::CreateRun.new(thread_id: thread_id, assistant_id: assistant_id)
      create_run_service.call
      create_run_service.run_id
    end
  end
end
