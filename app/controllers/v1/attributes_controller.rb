require "permissions"

class V1::AttributesController < ApplicationController
  before_action :authenticate_token!

  rescue_from KeyError do
    head 404
  end

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  def show
    subject_identifier = @token[:true_subject_identifier]
    claim_identifier = params[:id]

    unless Permissions.any_of_scopes_can_read(claim_identifier, @token[:scopes])
      head 401
      return
    end

    claim = Claim.find_claim(subject_identifier: subject_identifier, claim_identifier: claim_identifier)
    render json: claim.to_anonymous_hash
  end

  def update; end
end
