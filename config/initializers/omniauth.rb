# init Omniauth config
Rails.application.config.middleware.use OmniAuth::Builder do
  provider  :facebook,
            Rails.application.secrets.fb_api_key,
            Rails.application.secrets.fb_api_secret,
            :scope => 'email,public_profile',
            :info_feilds => 'name,email',
            :callback_path => '/api/auth/facebook/callback'
end
