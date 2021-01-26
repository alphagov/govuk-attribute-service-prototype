RSpec.describe "/v1/report/bigquery" do
  include ActiveJob::TestHelper

  let(:token_scopes) { [] }

  let(:headers) do
    {
      Accept: "application/json",
      Authorization: "Bearer #{token}",
    }
  end

  before do
    stub_token_response({
      true_subject_identifier: "42",
      pairwise_subject_identifier: "aaabbbccc",
      scopes: token_scopes,
    })
  end

  it "returns a 401" do
    post v1_report_bigquery_path, headers: token_headers
    expect(response).to have_http_status(:unauthorized)
  end

  context "with a valid token" do
    let(:token_scopes) { %i[reporting_access] }

    it "returns a 202" do
      post v1_report_bigquery_path, headers: token_headers
      expect(response).to have_http_status(:accepted)
    end

    it "enqueues a job" do
      post v1_report_bigquery_path, headers: token_headers
      assert_enqueued_jobs 1, only: BigqueryReportExportJob
    end
  end
end
