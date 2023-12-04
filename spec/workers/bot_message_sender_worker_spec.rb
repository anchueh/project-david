require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BotMessageSenderWorker, type: :worker do
  describe '#perform' do
    let(:user_id) { 'user123' }
    let(:message) { "Hello there! How are you?\nI'm fine, thanks." }
    let(:worker) { described_class.new }
    let(:expected_sentences) { ["Hello there!", "How are you?", "I'm fine, thanks."] }

    before do
      Sidekiq::Testing.inline!

      mock_send_action_service = instance_double(MessengerServices::SendAction)
      allow(MessengerServices::SendAction).to receive(:new).and_return(mock_send_action_service)
      allow(mock_send_action_service).to receive(:call)

      mock_send_message_service = instance_double(MessengerServices::SendMessage)
      allow(MessengerServices::SendMessage).to receive(:new).and_return(mock_send_message_service)
      allow(mock_send_message_service).to receive(:call)

      allow(worker).to receive(:sleep)
    end

    it 'splits the message into sentences and sends them separately' do
      worker.perform(user_id, message)

      expected_sentences.each do |sentence|
        expect(MessengerServices::SendAction).to have_received(:new).with(user_id: user_id, action: 'typing_on')
        expect(MessengerServices::SendMessage).to have_received(:new).with(user_id: user_id, message: sentence)
      end
    end

    it 'calculates and applies typing duration for each sentence' do
      expected_durations = expected_sentences.map do |sentence|
        worker.send(:get_typing_duration, sentence, BotMessageSenderWorker::DEFAULT_TYPING_SPEED)
      end

      worker.perform(user_id, message)

      expected_durations.each do |duration|
        expect(worker).to have_received(:sleep).with(duration / 1000.0)
      end
    end
  end
end
