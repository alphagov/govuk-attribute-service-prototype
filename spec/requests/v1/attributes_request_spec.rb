RSpec.describe "/v1/attributes/:id" do
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
    context "with a valid token" do
      before { stub_token_response token_hash }

      context "the token has permissions to read the claim" do
        let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

        it "returns 404" do
          get "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers
          expect(response).to have_http_status(:not_found)
        end

        context "the claim exists" do
          let!(:claim) do
            FactoryBot.create(
              :claim,
              subject_identifier: token_hash[:true_subject_identifier],
              claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
              claim_value: "hello world",
            )
          end

          it "returns the claim value" do
            get "/v1/attributes/#{claim.claim_name}", headers: headers
            expect(response).to be_successful

            json = JSON.parse(response.body).symbolize_keys
            expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
            expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
          end

          context "the token has permission to write the claim" do
            let(:token_scopes) { [Permissions::TEST_WRITE_SCOPE] }

            it "returns the claim value" do
              get "/v1/attributes/#{claim.claim_name}", headers: headers
              expect(response).to be_successful

              json = JSON.parse(response.body).symbolize_keys
              expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
              expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
            end
          end
        end
      end

      context "the token does not have permission" do
        it "returns a 403" do
          get "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe "PUT/PATCH" do
    let(:new_claim_value) { { "claim_key" => "new claim value" } }

    let(:params) { { value: new_claim_value.to_json } }

    context "with a valid token" do
      before { stub_token_response token_hash }

      context "the token has permissions to write the claim" do
        let(:token_scopes) { [Permissions::TEST_WRITE_SCOPE] }

        it "creates the claim" do
          expect { put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params }.to(change { Claim.count })
          expect(response).to be_successful
          expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
        end

        context "the claim exists" do
          let!(:claim) do
            FactoryBot.create(
              :claim,
              subject_identifier: token_hash[:true_subject_identifier],
              claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
              claim_value: "hello world",
            )
          end

          it "updates the existing claim" do
            expect { put "/v1/attributes/#{claim.claim_name}", headers: headers, params: params }.to_not(change { Claim.count })
            expect(response).to be_successful
            expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
          end
        end
      end

      context "the token has permission to read the claim" do
        let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

        it "does not grant write access" do
          put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "the token does not have permission" do
        it "returns a 403" do
          put "/v1/attributes/#{Permissions::TEST_CLAIM_NAME}", headers: headers, params: params
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
