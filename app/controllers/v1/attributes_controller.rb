class V1::AttributesController < ApplicationController
  before_action :authenticate_token!

  rescue_from KeyError do
    head :not_found
  end

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  rescue_from ActionController::ParameterMissing do
    head :bad_request
  end

  def show
    head :forbidden and return unless can_read?(claim_name)

    claim = Claim.find_claim(subject_identifier: subject_identifier, claim_identifier: claim_identifier)
    render json: claim.to_anonymous_hash
  end

  def update
    head :forbidden and return unless can_write?(claim_name)

    claim = Claim.upsert!(subject_identifier: subject_identifier, claim_identifier: claim_identifier, claim_value: JSON.parse(params.fetch(:value)))
    render json: claim.to_anonymous_hash
  end

  def destroy
    head :forbidden and return unless can_write?(claim_name)

    Claim.find_claim(subject_identifier: subject_identifier, claim_identifier: claim_identifier).destroy!
    head :no_content
  end

private

  def subject_identifier
    @token[:true_subject_identifier]
  end

  def claim_identifier
    Permissions.name_to_uuid(claim_name)
  end

  def claim_name
    params.fetch(:id).to_sym
  end
end
