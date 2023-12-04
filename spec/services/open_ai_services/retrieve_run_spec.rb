require 'rails_helper'

RSpec.describe OpenAIServices::RetrieveRun, type: :service do
  describe '#call' do
    let(:thread_id) { 'thread123' }
    let(:run_id) { 'run456' }
    let(:service) { described_class.new(thread_id: thread_id, run_id: run_id) }

    before do
      mock_openai_client = instance_double(OpenAI::Client)
      allow(OpenAI::Client).to receive(:new).and_return(mock_openai_client)
      allow(mock_openai_client).to receive(:runs).and_return(double('runs', retrieve: mock_response))
    end

    let(:mock_response) do
      { 'status' => 'completed' }
    end

    context 'when all required parameters are provided' do
      it 'retrieves a run and sets status' do
        expect(service.call).to be(service)
        expect(service.status).to eq('completed')
      end
    end

    context 'when thread_id is missing' do
      let(:thread_id) { nil }

      it 'adds an error for missing thread_id' do
        expect(service.call).to be(service)
        expect(service.errors).to include(I18n.t('open_ai_services.thread_id_is_blank'))
      end
    end

    context 'when run_id is missing' do
      let(:run_id) { nil }

      it 'adds an error for missing run_id' do
        expect(service.call).to be(service)
        expect(service.errors).to include(I18n.t('open_ai_services.run_id_is_blank'))
      end
    end
  end
end
