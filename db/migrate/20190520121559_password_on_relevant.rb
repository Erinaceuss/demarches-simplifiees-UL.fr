class PasswordOnRelevant < ActiveRecord::Migration[5.2]
  def change
    rename_column :gestionnaires , :encrypted_password, :password
    rename_column :administrateurs , :encrypted_password, :password
    rename_column :administrations , :encrypted_password, :password
  end
end
