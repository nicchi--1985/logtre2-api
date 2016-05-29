class User < ApplicationRecord
  def self.create_with_omniauth(auth)
    create! do |user|
      user.name = auth['info']['name']
      user.email = auth['info']['email']
      user.uid = auth['uid']
      user.provider = auth['provider']
    end
  end
end
