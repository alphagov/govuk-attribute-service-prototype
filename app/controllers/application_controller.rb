require "rest-client"

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_token!
    authenticate_with_http_token do |token, _options|
      uri = "#{ENV['ACCOUNT_MANAGER_URL']}/api/v1/deanonymise-token?token=#{token}"
      response = with_retries do
        RestClient.get uri, { accept: :json, authorization: "Bearer #{ENV['ACCOUNT_MANAGER_TOKEN']}" }
      end
      token_json = JSON.parse(response.body)
      @token = {
        true_subject_identifier: token_json["true_subject_identifier"].to_s,
        pairwise_subject_identifier: token_json["pairwise_subject_identifier"].to_s,
        scopes: token_json["scopes"].map(&:to_sym),
      }
    rescue RestClient::Forbidden, RestClient::NotFound, RestClient::Gone
      head :unauthorized
      return
    rescue RestClient::RequestFailed, JSON::ParserError, URI::InvalidURIError => e
      Raven.capture_exception(e)
      head :internal_server_error
      return
    end

    head :unauthorized unless @token
  end

  def can_read?(claim_name)
    !@token.nil? && Permissions.any_of_scopes_can_read(claim_name, @token[:scopes])
  end

  def can_write?(claim_name)
    !@token.nil? && Permissions.any_of_scopes_can_write(claim_name, @token[:scopes])
  end

  def with_retries(attempts = 3)
    yield
  rescue RestClient::Exceptions::Timeout, RestClient::ServerBrokeConnection, RestClient::BadGateway, RestClient::GatewayTimeout => e
    attempts -= 1
    retry unless attempts.zero?

    raise e
  end
end
