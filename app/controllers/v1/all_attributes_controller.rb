class V1::AllAttributesController < ApplicationController
  before_action :authenticate_token!

  def destroy
    all_subject_attributes = Claim.where(subject_identifier: subject_identifier)

    permissions = all_subject_attributes.map { |claim| Permissions.any_of_scopes_can_write(claim.claim_name, token_scopes) }

    unless permissions.all?
      head 401
      return
    end

    all_subject_attributes.destroy_all
    head 200
  end

private

  def subject_identifier
    @token[:true_subject_identifier]
  end

  def token_scopes
    @token[:scopes]
  end
end
