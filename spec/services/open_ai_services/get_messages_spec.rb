require 'rails_helper'

RSpec.describe OpenAIServices::GetMessages, type: :service do
  describe '#call' do
    let(:thread_id) { '12345' }
    let(:service) { described_class.new(thread_id: thread_id) }

    before do
      allow_any_instance_of(OpenAI::Client).to receive(:messages).and_return(double('list', list: mock_response))
    end

    context 'when thread_id is provided' do
      let(:mock_response) { { "data" => ["message1", "message2"] } }

      it 'retrieves messages' do
        service.call
        expect(service.data).to eq(["message1", "message2"])
        expect(service.success?).to be true
      end
    end

    context 'when thread_id is blank' do
      let(:thread_id) { nil }
      let(:mock_response) { {} }

      it 'adds an error' do
        service.call
        expect(service.errors).to include(I18n.t('open_ai_services.thread_id_is_blank'))
      end
    end
  end
end
