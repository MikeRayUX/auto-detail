class CreateWorkSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :work_sessions do |t|
      t.belongs_to :washer
      t.datetime :last_checked_in_at
      t.datetime :terminated_at
      t.string :secure_id

      t.timestamps
    end
  end
end
