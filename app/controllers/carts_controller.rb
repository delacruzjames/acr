class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: payload
  end

  def add_item
    code = params.require(:code)
    @cart.add(code)
    render json: payload
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :unprocessable_entity
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
    priced = @cart.priced # => { lines:, total: }

    items = priced[:lines].map do |code, h|
      p    = Product.find_by!(code: code)
      unit = h[:unit_price].to_d
      eff  = (h[:effective_unit_price] || unit).to_d
      qty  = h[:qty].to_i

      # Use override when present (e.g., BOGOF). Else eff * qty.
      line = (h[:line_total_override] || (eff * qty)).round(2)

      {
        code: code,
        name: p.name,
        unit_price: unit.to_f,
        effective_unit_price: eff.to_f,
        quantity: qty,
        line_total: line.to_f
      }
    end

    { items: items, total: priced[:total].to_f }
  end
end
