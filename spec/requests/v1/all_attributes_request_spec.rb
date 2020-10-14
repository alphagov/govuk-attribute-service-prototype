require "rails_helper"

RSpec.describe "V1::AllAttributes", type: :request do
  around do |example|
    ClimateControl.modify(ACCOUNT_MANAGER_URL: "https://account-manager", ACCOUNT_MANAGER_TOKEN: "account-manager-token") do
      example.run
    end
  end

  let(:token) { "123456" }

  let(:headers) { { accept: "application/json", authorization: "Bearer #{token}" } }

  let(:token_scopes) { [Permissions::DELETE_SCOPE] }

  let(:true_subject_identifier) { 42 }

  let(:token_hash) do
    {
      true_subject_identifier: true_subject_identifier,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: token_scopes,
    }
  end

  let!(:claim) do
    FactoryBot.create(
      :claim,
      subject_identifier: token_hash[:true_subject_identifier],
      claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
      claim_value: "foo",
    )
  end

  describe "DELETE" do
    describe "/attributes/all" do
      context "with an invalid token" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(status: 404)
        end

        it "returns 401" do
          delete "/v1/attributes/all", headers: headers
          expect(response).to have_http_status(401)
        end

        it "does not delete attributes" do
          expect(Claim.where(subject_identifier: claim.subject_identifier)).to be_present
        end
      end

      context "with an expired token" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(status: 410)
        end

        it "returns 401" do
          delete "/v1/attributes/all", headers: headers
          expect(response).to have_http_status(401)
        end

        it "does not delete attributes" do
          expect(Claim.where(subject_identifier: claim.subject_identifier)).to be_present
        end
      end

      context "with the account manager down" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(status: 500)
        end

        it "returns 500" do
          delete "/v1/attributes/all", headers: headers
          expect(response).to have_http_status(500)
        end

        it "does not delete attributes" do
          expect(Claim.where(subject_identifier: claim.subject_identifier)).to be_present
        end
      end

      context "with a valid token" do
        before do
          stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
            .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
            .to_return(body: token_hash.to_json)
        end

        it "returns 200" do
          delete "/v1/attributes/all", headers: headers
          expect(response).to be_successful
        end

        it "removes all claims belonging to that subject" do
          delete "/v1/attributes/all", headers: headers
          expect(Claim.where(subject_identifier: claim.subject_identifier)).not_to be_present
        end

        context "without permission to delete the claims" do
          let(:token_scopes) { %i[some_other_scope] }

          it "returns 401" do
            delete "/v1/attributes/all", headers: headers
            expect(response).to have_http_status(401)
          end

          it "does not delete attributes" do
            expect(Claim.where(subject_identifier: claim.subject_identifier)).to be_present
          end
        end
      end
    end
  end
end
