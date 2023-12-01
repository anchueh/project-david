module BotServices
  class HandleRunWatcher < ::ServiceBase
    attr_reader :thread_id, :run_id, :user_id

    def initialize(thread_id:, run_id:, user_id:)
      super
      @thread_id = thread_id
      @run_id = run_id
      @user_id = user_id
    end

    def call
      watch_run
      handle_run_completion
      self
    rescue StandardError => e
      add_error e.message
    end

    private

    def watch_run(timeout: 60)
      run_status = retrieve_run_status(thread_id: @thread_id, run_id: @run_id)
      start_time = Time.now

      while OpenAIServices::RunStatus.running?(run_status)
        if Time.now - start_time > timeout
          raise "Run timed out"
        end
        sleep(1)
        run_status = retrieve_run_status(thread_id: @thread_id, run_id: @run_id)
      end

      raise "Run failed" if run_status != OpenAIServices::RunStatus::COMPLETED

      run_status
    end

    def handle_run_completion
      messages = get_messages(thread_id: @thread_id)
      latest_message = messages.first
      raise "Latest message is not from assistant" unless latest_message.dig("role").eql?("assistant")

      BotMessageSenderWorker.perform_async(@user_id, latest_message.dig("content", 0, "text", "value"))
    end

    def retrieve_run_status(thread_id:, run_id:)
      retrieve_run_service = OpenAIServices::RetrieveRun.new(thread_id: thread_id, run_id: run_id)
      retrieve_run_service.call
      retrieve_run_service.status
    end

    def get_messages(thread_id:)
      get_messages_service = OpenAIServices::GetMessages.new(thread_id: thread_id)
      get_messages_service.call
      get_messages_service.data
    end
  end
end
