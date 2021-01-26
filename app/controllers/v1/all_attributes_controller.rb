class V1::AllAttributesController < ApplicationController
  before_action :authenticate_token!

  def destroy
    unless token_scopes.include? Permissions::DELETE_SCOPE
      head 401
      return
    end

    Claim.where(subject_identifier: subject_identifier).destroy_all

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
