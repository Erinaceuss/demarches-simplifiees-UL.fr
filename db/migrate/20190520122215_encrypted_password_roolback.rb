class EncryptedPasswordRoolback < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :password, :encrypted_password
    rename_column :administrations,  :password, :encrypted_password
    rename_column :administrateurs,  :password, :encrypted_password
    rename_column :gestionnaires,  :password, :encrypted_password
  end
end
