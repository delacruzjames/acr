class ProductsController < ApplicationController
  def index
    render json: Product.order(:code).as_json(only: %i[id code name price])
  end
end
