# frozen_string_literal: true

require "google/cloud/bigquery"

class BigqueryReportExportJob < ApplicationJob
  DATASET_NAME = "daily"
  TABLE_NAME = "transition_checker"

  queue_as :default

  def perform
    bigquery = Google::Cloud::Bigquery.new(credentials: Rails.application.secrets.bigquery_credentials)
    dataset = bigquery.dataset DATASET_NAME
    table = dataset.table TABLE_NAME

    report = Report::TransitionChecker.new(
      user_id_pepper: Rails.application.secrets.reporting_user_id_pepper,
    ).as_rows

    delete_job = dataset.query_job "DELETE * FROM #{TABLE_NAME}"
    delete_job.wait_until_done!

    table.insert report
  end
end
