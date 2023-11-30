# frozen_string_literal: true

module OpenAIServices
  class RunStatus
    QUEUED = "queued"
    IN_PROGRESS = "in_progress"
    REQUIRES_ACTION = "requires_action"
    CANCELLING = "cancelling"
    CANCELLED = "cancelled"
    FAILED = "failed"
    COMPLETED = "completed"
    EXPIRED = "expired"

    def self.running?(status)
      [QUEUED, IN_PROGRESS, REQUIRES_ACTION, CANCELLING].include?(status)
    end
  end
end
