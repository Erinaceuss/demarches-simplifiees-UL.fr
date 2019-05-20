class AddLoginToRelevanttable < ActiveRecord::Migration[5.2]
  def change
    add_column :gestionnaires, :login , :string
    add_column :administrateurs, :login, :string

    #modifer plus tard ?
    add_column :administrations, :login, :string
  end
end
