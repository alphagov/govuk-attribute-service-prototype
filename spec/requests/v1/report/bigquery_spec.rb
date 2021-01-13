RSpec.describe "/v1/report/bigquery" do
  include ActiveJob::TestHelper

  let(:token) { "1234" }

  let(:token_scopes) { [] }

  let(:headers) do
    {
      Accept: "application/json",
      Authorization: "Bearer #{token}",
    }
  end

  around do |example|
    ClimateControl.modify(ACCOUNT_MANAGER_URL: "https://account-manager", ACCOUNT_MANAGER_TOKEN: "account-manager-token") do
      example.run
    end
  end

  before do
    stub_request(:get, "https://account-manager/api/v1/deanonymise-token?token=#{token}")
      .with(headers: { accept: "application/json", authorization: "Bearer account-manager-token" })
      .to_return(
        body: {
          true_subject_identifier: "42",
          pairwise_subject_identifier: "aaabbbccc",
          scopes: token_scopes,
        }.to_json,
      )
  end

  it "returns a 401" do
    post v1_report_bigquery_path, headers: headers
    expect(response).to have_http_status(401)
  end

  context "with a valid token" do
    let(:token_scopes) { %i[reporting_access] }

    it "returns a 202" do
      post v1_report_bigquery_path, headers: headers
      expect(response).to have_http_status(202)
    end

    it "enqueues a job" do
      post v1_report_bigquery_path, headers: headers
      assert_enqueued_jobs 1, only: BigqueryReportExportJob
    end
  end
end
