class Oidc::UserInfoController < ApplicationController
  before_action :authenticate_token!

  def show
    oidc_response = { sub: @token[:pairwise_subject_identifier] }

    render json: Claim
             .where(subject_identifier: @token[:true_subject_identifier])
             .select { |c| can_read? c.claim_name }
             .each_with_object(oidc_response) { |c, hsh| hsh[c.claim_name] = c.claim_value }
  end
end
