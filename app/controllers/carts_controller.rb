class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: payload
  end

  def add_item
    @cart.add(params.require(:code))
    render json: payload
  end

  def clear
    @cart.clear!
    render json: payload
  end

  private

  def set_cart
    @cart = current_cart
  end

  def payload
    {
      items: @cart.line_items.includes(:product).map { |li|
        p = li.product
        {
          code: p.code,
          name: p.name,
          unit_price: p.price.to_f,
          quantity: li.quantity,
          line_total: (li.quantity * p.price.to_d).to_f}
      },
      total: @cart.total.to_f
    }
  end
end
