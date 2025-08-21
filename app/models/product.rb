class Product < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def name_with_price
    "#{code} — #{name} (€#{format('%.2f', price)})"
  end
end
