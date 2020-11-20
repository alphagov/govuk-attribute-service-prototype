RSpec.describe "/v1/attributes/:id" do
  around do |example|
    ClimateControl.modify(ACCOUNT_MANAGER_URL: "https://account-manager", ACCOUNT_MANAGER_TOKEN: "account-manager-token") do
      example.run
    end
  end

  let(:token) { "123456" }

  let(:headers) { { accept: "application/json", authorization: "Bearer #{token}" } }

  let(:token_scopes) { %w[test_scope_1 test_scope_2] }

  let(:true_subject_identifier) { 42 }

  let(:token_hash) do
    {
      true_subject_identifier: true_subject_identifier,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: token_scopes,
    }
  end

  describe "GET" do
    context "if the claim exists" do
      let(:claim) do
        FactoryBot.create(
          :claim,
          subject_identifier: token_hash[:true_subject_identifier],
          claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
          claim_value: "hello world",
        )
      end

      context "with a valid token" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(body: token_hash.to_json)
        end

        context "if the token has permissions to read the claim" do
          let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

          it "returns 200" do
            get "/v1/attributes/#{claim.claim_name}", headers: headers
            expect(response).to be_successful
          end

          it "returns the claim value" do
            get "/v1/attributes/#{claim.claim_name}", headers: headers

            json = JSON.parse(response.body).symbolize_keys
            expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
            expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
          end
        end

        context "if the token has permission to write the claim" do
          let(:token_scopes) { [Permissions::TEST_WRITE_SCOPE] }

          it "also grants read access" do
            get "/v1/attributes/#{claim.claim_name}", headers: headers
            expect(response).to be_successful

            json = JSON.parse(response.body).symbolize_keys
            expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
            expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
          end
        end

        context "if the token does not have permission" do
          it "returns a 401" do
            get "/v1/attributes/#{claim.claim_name}", headers: headers
            expect(response).to have_http_status(401)
          end
        end
      end
    end

    context "if the claim doesn't exist" do
      context "with a valid token" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(body: token_hash.to_json)
        end

        context "if the token has permissions to read the claim" do
          let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

          it "returns 404" do
            get "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers
            expect(response).to have_http_status(404)
          end
        end

        context "if the token does not have permission" do
          it "returns a 401" do
            get "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers
            expect(response).to have_http_status(401)
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
    let(:new_claim_value) { { "claim_key" => "new claim value" } }

    let(:params) { { value: new_claim_value.to_json } }

    context "with a valid token" do
      before do
        stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
          .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
          .to_return(body: token_hash.to_json)
      end

      context "if the token has permissions to write the claim" do
        let(:token_scopes) { [Permissions::TEST_WRITE_SCOPE] }

        context "if the claim already exists" do
          let(:claim) do
            FactoryBot.create(
              :claim,
              subject_identifier: token_hash[:true_subject_identifier],
              claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
              claim_value: "hello world",
            )
          end

          it "returns 200" do
            put "/v1/attributes/#{claim.claim_name}", headers: headers, params: params
            expect(response).to be_successful
          end

          it "returns the new claim value" do
            put "/v1/attributes/#{claim.claim_name}", headers: headers, params: params
            expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
          end
        end

        context "if the claim does not already exist" do
          it "returns 200" do
            put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
            expect(response).to be_successful
          end

          it "returns the new claim value" do
            put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
            expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
          end
        end
      end

      context "if the token has permission to read the claim" do
        let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

        it "does not grant write access" do
          put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
          expect(response).to have_http_status(401)
        end
      end

      context "if the token does not have permission" do
        it "returns a 401" do
          put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
          expect(response).to have_http_status(401)
        end
      end
    end
  end
end
