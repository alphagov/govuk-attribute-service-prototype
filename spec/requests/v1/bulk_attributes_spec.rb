RSpec.describe "/v1/attributes" do
  let(:token_scopes) { [] }

  let(:token_hash) do
    {
      true_subject_identifier: 42,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: token_scopes,
    }
  end

  let(:params) do
    {
      attributes: {
        test_claim: "new value 1",
        test_claim_2: "new value 2",
      },
    }
  end

  before { stub_token_response token_hash }

  describe "POST" do
    context "the token has permissions to write all the claims" do
      let(:token_scopes) { %w[test_scope_write test_scope_write_2] }

      it "writes the claims" do
        expect { post "/v1/attributes", headers: token_headers, params: params }.to(change { Claim.count })
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq([
          { "claim_name" => "test_claim", "claim_value" => "new value 1" },
          { "claim_name" => "test_claim_2", "claim_value" => "new value 2" },
        ])
      end
    end

    context "the token has permissions to write some of the claims" do
      let(:token_scopes) { %w[test_scope_write] }

      it "does not grant write access" do
        expect { post "/v1/attributes", headers: token_headers, params: params }.to_not(change { Claim.count })
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "attributes parameter is unset" do
      let(:params) { {} }

      it "returns 400" do
        post "/v1/attributes", headers: token_headers, params: params
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
