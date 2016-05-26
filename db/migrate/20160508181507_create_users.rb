class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :name, null: false
      t.string   :email
      t.string  :uid
      t.string  :oauth_token
      t.datetime  :oauth_expires_at
      t.timestamps
    end
  end
end
