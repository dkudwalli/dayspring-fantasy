class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.string :team_one, null: false
      t.string :team_two, null: false
      t.string :venue
      t.datetime :starts_at, null: false

      t.timestamps
    end

    add_index :matches, :starts_at
  end
end
