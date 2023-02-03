# frozen_string_literal: true

class CreateWashPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :wash_preferences do |t|
      t.integer :user_id
      t.integer :detergent, default: 0
      t.integer :wash_temp, default: 0
      t.boolean :use_bleach_on_whites, default: true

      t.timestamps
    end
    add_index :wash_preferences, :user_id, unique: true
  end
end
