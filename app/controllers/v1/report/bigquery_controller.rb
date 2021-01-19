class V1::Report::BigqueryController < ApplicationController
  before_action :authenticate_token!

  def create
    head :forbidden and return unless @token[:scopes].include?(Permissions::REPORTING_SCOPE)

    BigqueryReportExportJob.perform_later

    head :accepted
  end
end
