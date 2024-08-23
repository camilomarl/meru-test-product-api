class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authenticate_request, only: [:create, :update, :destroy]

  # GET /products
  def index
    @pagy, @records = pagy(Product.all)
    
    Rails.logger.info "Products : #{@records.inspect}"
    # render json: @products
    render json: { data: @records, pagination: pagy_metadata(@pagy) }
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      Rails.logger.info "Product created successfully: #{@product.inspect}"
      render json: @product, status: :created, location: @product
    else
      Rails.logger.fatal "Fatal error during product creation: #{@product.errors}"
      render json: @product.errors, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.fatal "Fatal error during product creation: #{e.message}"
  end

  # GET /products/:id
  def show
    Rails.logger.debug "Showing product with ID: #{@product.id}"
    render json: @product
  rescue => e
    Rails.logger.error "Error showing product: #{e.message}"
  end

  def new
    @product = Product.new
  end

  def edit
    render json: @product
  end


  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product successfully destroyed'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error showing product: #{e.message}"
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:sku, :serial, :price, :stock)
  end
end
