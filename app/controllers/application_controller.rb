require "rest-client"

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_token!
    authenticate_with_http_token do |token, _options|
      uri = "#{ENV['ACCOUNT_MANAGER_URL']}/api/v1/deanonymise-token?token=#{token}"
      response = RestClient.get uri, { accept: :json, authorization: "Bearer #{ENV['ACCOUNT_MANAGER_TOKEN']}" }
      token_json = JSON.parse(response.body)
      @token = {
        true_subject_identifier: token_json["true_subject_identifier"].to_s,
        pairwise_subject_identifier: token_json["pairwise_subject_identifier"].to_s,
        scopes: token_json["scopes"].map(&:to_sym),
      }
    rescue RestClient::Forbidden, RestClient::NotFound, RestClient::Gone
      head 401
      return
    rescue RestClient::RequestFailed, JSON::ParserError, URI::InvalidURIError => e
      Raven.capture_exception(e)
      head 500
      return
    end

    head 401 unless @token
  end

  def can_read?(claim_name)
    !@token.nil? && Permissions.any_of_scopes_can_read(claim_name, @token[:scopes])
  end

  def can_write?(claim_name)
    !@token.nil? && Permissions.any_of_scopes_can_write(claim_name, @token[:scopes])
  end
end
