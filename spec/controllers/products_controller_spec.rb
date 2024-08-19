# spec/controllers/products_controller_spec.rb

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:product) { Product.create!(name: 'Product 1', sku: 'SKU1', serial: 'SERIAL1', price: 100.0, stock: 10) }
  let(:valid_attributes) { { name: 'Product 2', sku: 'SKU2', serial: 'SERIAL2', price: 200.0, stock: 20 } }
  let(:invalid_attributes) { { name: '', sku: '', serial: '', price: -1, stock: -10 } }

  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:fatal)
    allow(Rails.logger).to receive(:debug)
    allow(Rails.logger).to receive(:error)
  end

  describe 'GET #index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'logs the products' do
      expected_log_message = "Products : #{Product.all.inspect}"
      expect(Rails.logger).to have_received(:info).with(expected_log_message)
    end

    it 'returns all products' do
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'GET #show' do
    context 'when product exists' do
      before { get :show, params: { id: product.id } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'logs the product ID' do
        expect(Rails.logger).to have_received(:debug).with("Showing product with ID: #{product.id}")
      end

      it 'returns the product' do
        expect(JSON.parse(response.body)['id']).to eq(product.id)
      end
    end

    context 'when product does not exist' do
      before { get :show, params: { id: 'nonexistent' } }

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'logs an error' do
        expect(Rails.logger).to have_received(:error).with(/Error showing product/)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { product: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'logs the product creation' do
        post :create, params: { product: valid_attributes }
        expect(Rails.logger).to have_received(:info).with(/Product created successfully/)
      end
    end

    context 'with invalid parameters' do
      before { post :create, params: { product: invalid_attributes } }

      it 'does not create a new Product' do
        expect {
          post :create, params: { product: invalid_attributes }
        }.to change(Product, :count).by(0)
      end

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'logs a fatal error' do
        expect(Rails.logger).to have_received(:fatal).with(/Fatal error during product creation/)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Product', price: 150.0 } }

      before { patch :update, params: { id: product.id, product: new_attributes } }

      it 'updates the product' do
        product.reload
        expect(product.name).to eq('Updated Product')
        expect(product.price).to eq(150.0)
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end
    end

    context 'with invalid parameters' do
      before { patch :update, params: { id: product.id, product: invalid_attributes } }

      it 'does not update the product' do
        product.reload
        expect(product.name).to eq('Product 1')
      end

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the product' do
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)
    end

    it 'returns a successful response' do
      delete :destroy, params: { id: product.id }
      expect(response).to be_successful
    end

    it 'returns a success message' do
      delete :destroy, params: { id: product.id }
      expect(JSON.parse(response.body)['message']).to eq('Product successfully destroyed')
    end
  end
end
