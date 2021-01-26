RSpec.describe "/v1/attributes/:id" do
  let(:token_scopes) { [] }

  let(:token_hash) do
    {
      true_subject_identifier: 42,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: token_scopes,
    }
  end

  describe "GET" do
    context "with a valid token" do
      before { stub_token_response token_hash }

      context "the token has permissions to read the claim" do
        let(:token_scopes) { %w[test_scope_read] }

        it "returns 404" do
          get "/v1/attributes/test_claim", headers: token_headers
          expect(response).to have_http_status(:not_found)
        end

        context "the claim exists" do
          let!(:claim) do
            FactoryBot.create(
              :claim,
              subject_identifier: token_hash[:true_subject_identifier],
              claim_identifier: Permissions.name_to_uuid(:test_claim),
              claim_value: "hello world",
            )
          end

          it "returns the claim value" do
            get "/v1/attributes/#{claim.claim_name}", headers: token_headers
            expect(response).to be_successful

            json = JSON.parse(response.body).symbolize_keys
            expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
            expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
          end

          context "the token has permission to write the claim" do
            let(:token_scopes) { %w[test_scope_write] }

            it "returns the claim value" do
              get "/v1/attributes/#{claim.claim_name}", headers: token_headers
              expect(response).to be_successful

              json = JSON.parse(response.body).symbolize_keys
              expect(json[:claim_name]).to eq(claim.to_anonymous_hash[:claim_name].to_s)
              expect(json[:claim_value]).to eq(claim.to_anonymous_hash[:claim_value])
            end
          end
        end
      end

      context "the token does not have permission" do
        it "returns a 401" do
          get "/v1/attributes/test_claim", headers: token_headers
          expect(response).to have_http_status(:unauthorized)
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
        let(:token_scopes) { %w[test_scope_write] }

        it "creates the claim" do
          expect { put "/v1/attributes/test_claim", headers: token_headers, params: params }.to(change { Claim.count })
          expect(response).to be_successful
          expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
        end

        context "the claim exists" do
          let!(:claim) do
            FactoryBot.create(
              :claim,
              subject_identifier: token_hash[:true_subject_identifier],
              claim_identifier: Permissions.name_to_uuid(:test_claim),
              claim_value: "hello world",
            )
          end

          it "updates the existing claim" do
            expect { put "/v1/attributes/#{claim.claim_name}", headers: token_headers, params: params }.to_not(change { Claim.count })
            expect(response).to be_successful
            expect(JSON.parse(response.body).symbolize_keys[:claim_value]).to eq(new_claim_value)
          end
        end
      end

      context "the token has permission to read the claim" do
        let(:token_scopes) { %w[test_scope_read] }

        it "does not grant write access" do
          put "/v1/attributes/test_claim", headers: token_headers, params: params
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "the token does not have permission" do
        it "returns a 401" do
          put "/v1/attributes/test_claim", headers: token_headers, params: params
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
