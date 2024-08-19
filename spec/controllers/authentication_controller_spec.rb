require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe 'POST #login' do
    let(:user) { User.create!(email: 'user@example.com', password: 'password123') }

    before do
      allow(Rails.logger).to receive(:info)
    end

    context 'when credentials are correct' do
      before do
        allow(JsonWebToken).to receive(:encode).and_return('fake_token')
        post :login, params: { email: user.email, password: 'password123' }
      end

      it 'logs the correct messages' do
        expect(Rails.logger).to receive(:info).with(" >>>>>>> In login")
        expect(Rails.logger).to receive(:info).with(" >>>>>>> user #{user.inspect}")
        post :login, params: { email: user.email, password: 'password123' }
      end

      it 'returns a JWT token' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['token']).to eq('fake_token')
      end
    end

    context 'when credentials are incorrect' do
      before do
        post :login, params: { email: user.email, password: 'wrongpassword' }
      end

      it 'logs the correct messages' do
        expect(Rails.logger).to receive(:info).with(" >>>>>>> In login")
        expect(Rails.logger).to receive(:info).with(" >>>>>>> user #{user.inspect}")
        post :login, params: { email: user.email, password: 'wrongpassword' }
      end

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end

    context 'when user is not found' do
      before do
        post :login, params: { email: 'nonexistent@example.com', password: 'password123' }
      end

      it 'logs the correct messages' do
        expect(Rails.logger).to receive(:info).with(" >>>>>>> In login")
        expect(Rails.logger).to receive(:info).with(" >>>>>>> user nil")
        post :login, params: { email: 'nonexistent@example.com', password: 'password123' }
      end

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end
end
