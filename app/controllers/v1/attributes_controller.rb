class V1::AttributesController < ApplicationController
  before_action :authenticate_token!

  rescue_from KeyError do
    head 404
  end

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  rescue_from ActionController::ParameterMissing do
    head 400
  end

  def show
    unless Permissions.any_of_scopes_can_read(claim_identifier, token_scopes)
      head 401
      return
    end

    claim = Claim.find_claim(subject_identifier: subject_identifier, claim_identifier: claim_identifier)
    render json: claim.to_anonymous_hash
  end

  def update
    unless Permissions.any_of_scopes_can_write(claim_identifier, token_scopes)
      head 401
      return
    end

    claim = Claim.upsert!(subject_identifier: subject_identifier, claim_identifier: claim_identifier, claim_value: params.fetch(:value))
    render json: claim.to_anonymous_hash
  end

private

  def subject_identifier
    @token[:true_subject_identifier]
  end

  def token_scopes
    @token[:scopes]
  end

  def claim_identifier
    params.fetch(:id)
  end
end
