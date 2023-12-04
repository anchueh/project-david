require 'rails_helper'

RSpec.describe OpenAIServices::CreateMessage, type: :service do
  describe '#call' do
    let(:thread_id) { '12345' }
    let(:message) { 'Hello, OpenAI!' }
    let(:service) { described_class.new(thread_id: thread_id, message: message) }

    before do
      mock_client = instance_double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:messages).and_return(double(create: mock_response))
    end

    context 'when all required parameters are provided' do
      let(:mock_response) { { 'id' => 'message_id_123' } }

      it 'creates a message and sets message_id' do
        expect(service.call).to be(service)
        expect(service.message_id).to eq('message_id_123')
        expect(service.success?).to be true
      end
    end

    context 'when thread_id is missing' do
      let(:thread_id) { nil }

      it 'adds an error' do
        expect { service.call }.to raise_error(ArgumentError)
      end
    end

    context 'when message is missing' do
      let(:message) { nil }

      it 'adds an error' do
        expect { service.call }.to raise_error(ArgumentError)
      end
    end
  end
end
