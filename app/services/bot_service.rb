# frozen_string_literal: true

module BotService
  class Client
    def initialize
      @assistant_id = ENV["OPENAI_ASSISTANT_ID"]
    end

    def handle_message(message:, user_id:)
      puts "handle_message: #{message} #{user_id}"
      send_mark_seen_action(user_id: user_id)

      thread = get_thread(user_id: user_id)
      thread_id = thread[:thread_id]
      puts "thread_id: #{thread_id}"

      create_message(thread_id: thread_id, message: message)
      puts "message created"

      run_id = create_run(thread_id: thread_id, assistant_id: @assistant_id)
      run = watch_run(thread_id: thread_id, run_id: run_id)
      puts "run completed"
      unless run
        raise "Run failed"
      end

      messages = get_messages(thread_id: thread_id)
      latest_message = messages.first
      puts "latest_message: #{latest_message}"
      unless latest_message.dig("role").eql?("assistant")
        raise "Latest message is not from assistant"
      end

      puts "Sending message to user"
      BotMessageSenderWorker.perform_async(user_id, latest_message.dig("content", 0, "text", "value"))
    end

    def watch_run(thread_id:, run_id:, timeout: 60)
      run_status = retrieve_run_status(thread_id: thread_id, run_id: run_id)
      start_time = Time.now

      while OpenAIServices::RunStatus.running?(run_status)
        if Time.now - start_time > timeout
          raise "Run timed out"
        end
        sleep(1)
        run_status = retrieve_run_status(thread_id: thread_id, run_id: run_id)
      end

      if (run_status != OpenAIService::RunStatus::COMPLETED)
        raise "Run failed"
      end

      run
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

    def retrieve_run_status(thread_id:, run_id:)
      retrieve_run_service = OpenAIServices::RetrieveRun.new(thread_id: thread_id, run_id: run_id)
      retrieve_run_service.call
      retrieve_run_service.status
    end

    def get_messages(thread_id:, order: "desc", limit: 20, after: nil)
      get_messages_service = OpenAIServices::GetMessages.new(thread_id: thread_id)
      get_messages_service.call
      get_messages_service.data
    end
  end
end
