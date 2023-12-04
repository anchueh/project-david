require 'rails_helper'

RSpec.describe OpenAIServices::CreateThread, type: :service do
  describe '#call' do
    let(:service) { described_class.new }
    let(:fake_response) { {"id" => "123456"} }

    before do
      allow_any_instance_of(OpenAI::Client).to receive(:threads).and_return(double(create: fake_response))
    end

    context 'when the thread is successfully created' do
      it 'sets the thread_id' do
        service.call
        expect(service.thread_id).to eq("123456")
        expect(service.errors).to be_empty
      end
    end

    context 'when there is an error creating the thread' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive_message_chain(:threads, :create).and_raise(StandardError, 'Error')
      end

      it 'adds an error' do
        service.call
        expect(service.thread_id).to be_nil
      end
    end
  end
end
