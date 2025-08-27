class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy

  def add(code)
    product = Product.find_by!(code: code)
    li = line_items.find_or_initialize_by(product:)
    li.quantity = (li.quantity || 0) + 1
    li.save!
    li
  end

  def clear! = line_items.delete_all

  def snapshot
    line_items.includes(:product).each_with_object(Hash.new { |h,k| h[k] = { qty: 0, unit_price: 0.to_d } }) do |li, h|
      code = li.product.code
      h[code][:qty]        += li.quantity
      h[code][:unit_price]  = li.product.price.to_d
    end
  end

  def priced
    ::Pricing::ConfigEngine.new.price(snapshot)
  end

  def total = priced[:total]
end
