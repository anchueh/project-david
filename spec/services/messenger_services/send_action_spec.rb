require 'rails_helper'

RSpec.describe MessengerServices::SendAction, type: :service do
  describe '#call' do
    let(:user_id) { '6034297423330611' }
    let(:action) { 'typing_on' }
    let(:service) { described_class.new(user_id: user_id, action: action) }

    before do
      allow(service).to receive(:send_action).and_return(true)
    end

    context 'when all required parameters are provided' do
      it 'sends an action', vcr: { cassette_name: 'messenger_services/send_action' } do
        expect(service.call).to be(service)
        puts "Errors: #{service.errors}"
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

    context 'when action is missing' do
      let(:action) { nil }

      it 'adds an error' do
        expect(service.call).to be(service)
        expect(service.errors).to include(an_instance_of(StandardError))
        expect(service.errors.first.message).to eq(I18n.t('messenger_services.action_is_blank'))
      end
    end
  end
end
