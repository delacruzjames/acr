require "rails_helper"

RSpec.describe Cart, type: :model do
  it { is_expected.to have_many(:line_items).dependent(:destroy) }

  describe "#add and #total" do
    let!(:gr1) { Product.create!(code: "GR1", name: "Green Tea",    price: 3.11) }
    let!(:sr1) { Product.create!(code: "SR1", name: "Strawberries", price: 5.00) }
    let(:cart) { described_class.create! }

    it "creates or increments a line item" do
      expect { cart.add("GR1") }.to change { cart.line_items.count }.by(1)
      expect { cart.add("GR1") }.not_to change { cart.line_items.count }
      expect(cart.line_items.find_by(product: gr1).quantity).to eq(2)
    end

    it "sums quantity * unit price" do
      cart.add("GR1")
      cart.add("SR1")
      cart.add("SR1")
      expect(cart.total.to_f).to eq(3.11 + 5.00*2)
    end
  end

  describe "#snapshot" do
    let!(:gr1) { Product.create!(code: "GR1", name: "Green Tea", price: 3.11) }
    let!(:cart) { described_class.create! }

    it "returns qty and unit_price per product code" do
      2.times { cart.add("GR1") }
      snap = cart.snapshot
      expect(snap["GR1"][:qty]).to eq(2)
      expect(snap["GR1"][:unit_price].to_f).to eq(3.11)
    end
  end
end
