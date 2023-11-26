# frozen_string_literal: true

module BotService
  class Client
    def initialize(
      open_ai_service: OpenAIService::DavidClient.new,
      messenger_service: MessengerService::Client.new
    )
      @open_ai_service = open_ai_service
      @messenger_service = messenger_service
    end

    def send_message(message)
      response = @open_ai_service.get_response(message)
      @messenger_service.send_message("6034297423330611", response)
      { message: response }
    end

    def handle_message(message, user_id)
      puts "handle_message: #{message} #{user_id}"
      thread = get_thread(user_id)
      thread_id = thread[:thread_id]
      puts "thread_id: #{thread_id}"

      @open_ai_service.create_message(thread_id, message)
      puts "message created"

      run_id = @open_ai_service.create_run(thread_id)
      run = watch_run(thread_id, run_id)
      puts "run completed"
      unless run
        raise "Run failed"
      end

      messages = @open_ai_service.get_messages(thread_id)
      latest_message = messages.first
      puts "latest_message: #{latest_message}"
      unless latest_message.dig("role").eql?("assistant")
        raise "Latest message is not from assistant"
      end

      send_bot_message(user_id, latest_message.dig("content", 0, "text", "value"))
    end

    def send_bot_message(user_id, message)
      puts "send_bot_message: #{user_id} #{message}"
      @messenger_service.send_message(user_id, message)
      puts "message sent"
    end

    def watch_run(thread_id, run_id, timeout: 60)
      run = @open_ai_service.retrieve_run(thread_id, run_id)
      start_time = Time.now
      run_status = run.dig("status")

      while OpenAIService::RunStatus.running?(run_status)
        if Time.now - start_time > timeout
          raise "Run timed out"
        end
        sleep(1)
        run = @open_ai_service.retrieve_run(thread_id, run_id)
        run_status = run.dig("status")
      end

      if (run_status != OpenAIService::RunStatus::COMPLETED)
        raise "Run failed"
      end

      run
    end

    def get_thread(user_id)
      user_thread = UserThread.find_by(user_id: user_id)
      unless user_thread
        thread_id = @open_ai_service.create_thread
        user_thread = UserThread.create(user_id: user_id, thread_id: thread_id)
      end
      user_thread
    end
  end
end
