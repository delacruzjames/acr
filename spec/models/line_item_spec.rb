require "rails_helper"

RSpec.describe LineItem, type: :model do
  let!(:cart)    { Cart.create! }
  let!(:product) { Product.create!(code: "ZZ1", name: "Test", price: 1) }

  subject(:line_item) { described_class.new(cart: cart, product: product, quantity: 1) }

  it { is_expected.to belong_to(:cart) }
  it { is_expected.to belong_to(:product) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

  it do
    # subject supplies required attrs so the matcher can create the existing record
    is_expected.to validate_uniqueness_of(:product_id).scoped_to(:cart_id)
  end
end
