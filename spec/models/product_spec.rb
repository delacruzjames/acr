require 'rails_helper'

RSpec.describe Product, type: :model do
  # baseline valid record so uniqueness matcher has a valid subject
  subject { described_class.new(code: "GR1", name: "Green Tea", price: 3.11) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe "database" do
    it { is_expected.to have_db_index(:code).unique(true) }
  end

  describe "#name_with_price" do
    it "formats code, name, and price to 2 decimals" do
      expect(subject.name_with_price).to eq("GR1 — Green Tea (€3.11)")
    end
  end
end
