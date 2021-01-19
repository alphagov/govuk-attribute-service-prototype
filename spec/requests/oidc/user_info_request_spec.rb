RSpec.describe "/oidc/user_info" do
  around do |example|
    ClimateControl.modify(ACCOUNT_MANAGER_URL: "https://account-manager", ACCOUNT_MANAGER_TOKEN: "account-manager-token") do
      example.run
    end
  end

  let(:token) { "123456" }

  let(:headers) { { accept: "application/json", authorization: "Bearer #{token}" } }

  let(:token_scopes) { %w[test_scope_1 test_scope_2] }

  let(:token_hash) do
    {
      true_subject_identifier: "true-subject-identifier",
      pairwise_subject_identifier: "pairwise-subject-identifier",
      scopes: token_scopes,
    }
  end

  describe "GET" do
    context "with a valid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(body: token_hash.to_json)
      end

      it "returns 200" do
        get "/oidc/user_info", headers: headers
        expect(response).to be_successful
      end

      it "includes the pairwise subject identifier" do
        get "/oidc/user_info", headers: headers
        expect(JSON.parse(response.body)).to include("sub" => token_hash[:pairwise_subject_identifier])
      end

      it "does not include the true subject identifier" do
        get "/oidc/user_info", headers: headers
        expect(response.body).to_not include(token_hash[:true_subject_identifier])
      end

      context "a claim exists" do
        let!(:claim) do
          FactoryBot.create(
            :claim,
            subject_identifier: token_hash[:true_subject_identifier],
            claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
            claim_value: "hello world",
          )
        end

        it "doesn't include the claim in the response" do
          get "/oidc/user_info", headers: headers
          expect(response.body).to_not include(claim.claim_identifier)
        end

        context "the token has access to the claim" do
          let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

          it "includes the claim in the response" do
            get "/oidc/user_info", headers: headers
            expect(JSON.parse(response.body)).to include(claim.claim_name.to_s => claim.claim_value)
          end
        end
      end
    end

    context "with an invalid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 404)
      end

      it "returns 401" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 410)
      end

      it "returns 401" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with the account manager down" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(status: 500)
      end

      it "returns 500" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
