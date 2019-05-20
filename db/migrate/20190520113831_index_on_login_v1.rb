class IndexOnLoginV1 < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, :email
    remove_index :administrateurs, :email
    remove_index :gestionnaires, :email

    add_index :users, :login, unique:true
    add_index :administrateurs, :login, unique:true
    add_index :gestionnaires, :login, unique:true
  end
end
