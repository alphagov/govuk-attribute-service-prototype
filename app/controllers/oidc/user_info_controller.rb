class Oidc::UserInfoController < ApplicationController
  before_action :authenticate_token!

  def show
    oidc_response = { sub: pairwise_subject_identifier }

    render json: Claim
             .where(subject_identifier: subject_identifier)
             .select { |c| Permissions.any_of_scopes_can_read(c.claim_name, token_scopes) }
             .each_with_object(oidc_response) { |c, hsh| hsh[c.claim_name] = c.claim_value }
  end

private

  def subject_identifier
    @token[:true_subject_identifier]
  end

  def pairwise_subject_identifier
    @token[:pairwise_subject_identifier]
  end

  def token_scopes
    @token[:scopes]
  end
end
