RSpec.describe "E2E attributes" do
  SAMPLE_VALUES = {
    "boolean true" => true,
    "boolean false" => false,
    "integer" => 1,
    "string" => "hello world",
    "empty hash" => {},
    "simple hash" => { "hello" => "world" },
    "nested hash" => { "hello" => { "world" => true, "mundo" => false } },
  }.freeze

  before do
    stub_token_response({
      true_subject_identifier: 42,
      pairwise_subject_identifier: "aaabbbccc",
      scopes: %w[test_scope_write test_scope_write_2],
    })
  end

  context "single update endpoint" do
    SAMPLE_VALUES.each do |test_name, claim_value|
      it "sets '#{test_name}'" do
        put "/v1/attributes/test_claim", headers: token_headers, params: { value: claim_value.to_json }
        expect(response).to be_successful

        expect_attribute_has_value "test_claim", claim_value
      end
    end
  end

  context "bulk update endpoint" do
    SAMPLE_VALUES.each do |test_name1, claim_value1|
      SAMPLE_VALUES.each do |test_name2, claim_value2|
        it "sets '#{test_name1}' and '#{test_name2}'" do
          post "/v1/attributes", headers: token_headers, params: { attributes: { test_claim: claim_value1.to_json, test_claim_2: claim_value2.to_json } }
          expect(response).to be_successful

          expect_attribute_has_value "test_claim", claim_value1
          expect_attribute_has_value "test_claim_2", claim_value2
        end
      end
    end
  end

  def expect_attribute_has_value(name, value)
    get "/oidc/user_info", headers: token_headers
    expect(JSON.parse(response.body)).to include(name => value)
  end
end
