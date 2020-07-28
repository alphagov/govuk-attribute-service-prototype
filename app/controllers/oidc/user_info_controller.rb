class Oidc::UserInfoController < ApplicationController
  before_action :authenticate_token!

  def show; end
end
