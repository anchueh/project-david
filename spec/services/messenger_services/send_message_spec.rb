require 'rails_helper'

RSpec.describe MessengerServices::SendMessage, type: :service do
  describe '#call' do
    let(:user_id) { '123456' }
    let(:message) { 'Hello!' }
    let(:service) { described_class.new(user_id: user_id, message: message) }

    before do
      allow(service).to receive(:send_message).and_return(true)
    end

    context 'when all required parameters are provided' do
      it 'sends a message' do
        expect(service.call).to be(service)
        expect(service.success?).to be true
      end
    end

    context 'when user_id is missing' do
      let(:user_id) { nil }

      it 'adds an error' do
        expect(service.call).to be(service)
        expect(service.errors).to include(an_instance_of(StandardError))
        expect(service.errors.first.message).to eq(I18n.t('messenger_services.user_id_is_blank'))
      end
    end

    context 'when message is missing' do
      let(:message) { nil }

      it 'adds an error' do
        expect(service.call).to be(service)
        expect(service.errors).to include(an_instance_of(StandardError))
        expect(service.errors.first.message).to eq(I18n.t('messenger_services.message_is_blank'))
      end
    end
  end
end
