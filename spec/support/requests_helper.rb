module RequestsHelper
  def stub_token_response(token_hash, status: 200)
    stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{bearer_token}")
      .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
      .to_return(status: status, body: token_hash&.to_json)
  end

  def token_headers
    { accept: "application/json", authorization: "Bearer #{bearer_token}" }
  end

  def bearer_token
    "breadbread"
  end
end

RSpec.configuration.send :include, RequestsHelper
