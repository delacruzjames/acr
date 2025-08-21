require "rails_helper"

RSpec.describe "Products", type: :request do
  it "returns http success" do
    get "/products"
    expect(response).to have_http_status(:success)
  end

  it "returns a list of products" do
    Product.create!(code: "AA1", name: "X", price: 1)
    get "/products"
    json = JSON.parse(response.body)
    expect(json).to be_an(Array)
    expect(json.first.keys).to include("id","code","name","price")
  end
end
