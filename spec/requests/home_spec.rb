require "rails_helper"

RSpec.describe "Home", type: :request do
  it "returns http success for root" do
    get root_path
    expect(response).to have_http_status(:success)
  end
end
