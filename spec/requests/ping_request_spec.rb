require "rails_helper"

RSpec.describe "Ping", type: :request do
  describe "GET" do
    it "returns a 200" do
      get "/ping"
      expect(response).to be_successful
    end
  end
end
