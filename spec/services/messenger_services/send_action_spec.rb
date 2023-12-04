require 'rails_helper'

RSpec.describe MessengerServices::SendAction, type: :service do
  describe '#call' do
    let(:user_id) { '123456' }
    let(:action) { 'typing_on' }
    let(:service) { described_class.new(user_id: user_id, action: action) }

    before do
      allow(service).to receive(:send_action).and_return(true)
    end

    context 'when all required parameters are provided' do
      it 'sends an action' do
        expect(service.call).to be(service)
        expect(service.success?).to be true
      end
    end

    context 'when user_id is missing' do
      let(:user_id) { nil }

      it 'adds an error' do
        expect(service.call).to be(service)
        expect(service.errors).to include(I18n.t('messenger_services.user_id_is_blank'))
      end
    end

    context 'when action is missing' do
      let(:action) { nil }

      it 'adds an error' do
        expect(service.call).to be(service)
        expect(service.errors).to include(I18n.t('messenger_services.action_is_blank'))
      end
    end
  end
end
