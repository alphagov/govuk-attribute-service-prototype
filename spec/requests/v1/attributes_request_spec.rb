require "rails_helper"

RSpec.describe "V1::Attributes", type: :request do
  before do
    ENV["ACCOUNT_MANAGER_URL"] = "https://account-manager"
    ENV["ACCOUNT_MANAGER_TOKEN"] = "account-manager-token"
  end

  let(:token) { "123456" }

  let(:headers) { { accept: "application/json", authorization: "Bearer #{token}" } }

  let(:token_json) do
    {
      true_subject_identifier: 42,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: %w[scope1 scope2],
    }.to_json
  end

  describe "GET" do
    context "with a valid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(body: token_json)
      end

      it "returns 200" do
        get "/v1/attributes/some-attribute", headers: headers
        expect(response).to be_successful
      end
    end

    context "with an invalid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 404)
      end

      it "returns 401" do
        get "/v1/attributes/some-attribute", headers: headers
        expect(response).to have_http_status(401)
      end
    end

    context "with an expired token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 410)
      end

      it "returns 401" do
        get "/v1/attributes/some-attribute", headers: headers
        expect(response).to have_http_status(401)
      end
    end

    context "with the account manager down" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 500)
      end

      it "returns 500" do
        get "/v1/attributes/some-attribute", headers: headers
        expect(response).to have_http_status(500)
      end
    end
  end

  describe "PUT/PATCH" do
    context "with a valid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(body: token_json)
      end

      it "returns 200" do
        put "/v1/attributes/some-attribute", headers: headers
        expect(response).to be_successful
      end
    end
  end
end
