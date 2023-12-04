require 'rails_helper'

RSpec.describe OpenAIServices::CreateRun, type: :service do
  let(:thread_id) { 'thread_12345' }
  let(:assistant_id) { 'assistant_123' }
  let(:service) { described_class.new(thread_id: thread_id, assistant_id: assistant_id) }

  before do
    allow_any_instance_of(OpenAI::Client).to receive(:runs).and_return(double('Run', create: mock_response))
  end

  describe '#call' do
    context 'when all required parameters are provided' do
      let(:mock_response) { { 'id' => 'run_67890' } }

      it 'successfully creates a run and sets run_id' do
        expect(service.call).to be(service)
        expect(service.run_id).to eq('run_67890')
      end
    end

    context 'when thread_id is missing' do
      let(:thread_id) { nil }
      let(:mock_response) { nil }

      it 'adds an error for missing thread_id' do
        expect(service.call).to be(service)
        expect(service.errors).to include(an_instance_of(StandardError))
        expect(service.errors.first.message).to eq(I18n.t('open_ai_services.thread_id_is_blank'))
      end
    end

    context 'when assistant_id is missing' do
      let(:assistant_id) { nil }
      let(:mock_response) { nil }

      it 'adds an error for missing assistant_id' do
        expect(service.call).to be(service)
        expect(service.errors).to include(an_instance_of(StandardError))
        expect(service.errors.first.message).to eq(I18n.t('open_ai_services.assistant_id_is_blank'))
      end
    end
  end
end
