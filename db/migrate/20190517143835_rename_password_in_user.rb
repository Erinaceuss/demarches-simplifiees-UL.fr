class RenamePasswordInUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users ,:encrypted_password,:passwordbin
  end
end
