# frozen_string_literal: true

require "google/cloud/bigquery"

class BigqueryReportExportJob < ApplicationJob
  class DeleteError < StandardError; end
  class InsertError < StandardError; end

  DATASET_NAME = "daily"
  TABLE_NAME = "transition_checker"

  queue_as :default

  def perform
    bigquery = Google::Cloud::Bigquery.new(credentials: Rails.application.secrets.bigquery_credentials)
    dataset = bigquery.dataset DATASET_NAME
    table = dataset.table TABLE_NAME

    delete_job = dataset.query_job "DELETE FROM #{TABLE_NAME} WHERE 1 = 1"
    delete_job.wait_until_done!
    raise DeleteError, delete_job.error.dig("message") if delete_job.failed?

    Report::TransitionChecker.new(
      user_id_pepper: Rails.application.secrets.reporting_user_id_pepper,
    ).in_batches do |rows|
      insert_response = table.insert rows
      raise InsertError, "errors: #{insert_response.error_count}" unless insert_response.success?
    end
  end
end
