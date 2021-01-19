RSpec.describe "/v1/attributes/all" do
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
      claim_identifier: Permissions.name_to_uuid(:test_claim),
      claim_value: "foo",
    )
  end

  describe "DELETE" do
    context "with a valid token" do
      before { stub_token_response token_hash }

      it "removes all claims belonging to that subject" do
        expect { delete "/v1/attributes/all", headers: headers }.to(change { Claim.count })
        expect(response).to be_successful
        expect(Claim.where(subject_identifier: claim.subject_identifier)).not_to be_present
      end

      context "without permission to delete the claims" do
        let(:token_scopes) { %i[some_other_scope] }

        it "returns 403" do
          expect { delete "/v1/attributes/all", headers: headers }.to_not(change { Claim.count })
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
