class V1::AllAttributesController < ApplicationController
  before_action :authenticate_token!

  def destroy
    head :forbidden and return unless @token[:scopes].include?(Permissions::DELETE_SCOPE)

    Claim.where(subject_identifier: @token[:true_subject_identifier]).destroy_all

    head :ok
  end
end
