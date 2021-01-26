class V1::BulkAttributesController < ApplicationController
  before_action :authenticate_token!

  rescue_from ActionController::ParameterMissing do
    head :bad_request
  end

  def update
    claims = params.fetch(:attributes).permit!.to_h.symbolize_keys

    can_write_all = claims.keys.all? do |claim_name|
      Permissions.any_of_scopes_can_write(claim_name, @token[:scopes])
    end

    head 401 and return unless can_write_all

    claim_hashes = claims.map do |claim_name, value|
      Claim.upsert!(
        subject_identifier: @token[:true_subject_identifier],
        claim_identifier: Permissions.name_to_uuid(claim_name),
        claim_value: value,
      ).to_anonymous_hash
    end

    render json: claim_hashes
  end
end
