# frozen_string_literal: true

module BotServices
  class HandleMessage < ::ServiceBase
    attr_reader :message, :user_id

    def initialize(message:, user_id:)
      super
      @message = message
      @user_id = user_id
    end
  end
end

