class CreateClaims < ActiveRecord::Migration[6.0]
  def change
    create_table :claims, primary_key: %i[subject_identifier claim_identifier] do |t|
      t.string :subject_identifier
      t.uuid :claim_identifier
      t.jsonb :claim_value
      t.index :subject_identifier
      t.index :claim_identifier
    end
  end
end
