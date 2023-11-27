# frozen_string_literal: true

module BotService
  class Client

    SENTENCE_REGEX = /(?<!\w\.\w.)(?<![A-Z][a.z]\.)(?<=\.|\?|\!|\n|(?<=\s|^)(?<!\s|^)(?<!\s|^))\s*/.freeze
    DEFAULT_TYPING_SPEED = 400 # characters per minute

    def initialize(
      open_ai_service: OpenAIService::DavidClient.new,
      messenger_service: MessengerService::Client.new,
      bot_message_sender_worker: BotMessageSenderWorker.new
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
      @messenger_service.send_action(user_id, "mark_seen")

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
