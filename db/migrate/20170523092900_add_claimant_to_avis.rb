class AddClaimantToAvis < ActiveRecord::Migration[5.0]
  def change
    add_reference :avis, :claimant, foreign_key: { to_table: :gestionnaires }, null: false
  end
end
