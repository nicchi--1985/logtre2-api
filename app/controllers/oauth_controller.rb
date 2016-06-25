class OauthController < ApplicationController
  skip_before_action :authenticate_request!
  def callback
    binding.pry
    auth = request.env['omniauth.auth']
    @user = User.find_by_provider_and_uid(auth['provider'], auth['uid']) || User.create_with_omniauth(auth)
    payload = build_payload(@user, auth)
    token = JsonWebToken.encode(payload)
    query = "token=" + token
    url = URI::HTTP.build(host: 'local.logtre.com', path: '/login', query: query).to_s
    redirect_to url
  end

  def destroy
  end

  private
  def build_payload(user, auth)
    return {
      user_id: user.id,
      provider: user.provider,
      credentials: auth['credentials']
    }
  end
end
