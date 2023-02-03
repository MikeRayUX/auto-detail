# frozen_string_literal: true

class CreateCourierProblems < ActiveRecord::Migration[5.2]
  def change
    create_table :courier_problems do |t|
      t.belongs_to :order
      t.belongs_to :worker
      t.integer :occured_during_task
      t.integer :occured_during_step
      t.string :problem_encountered
      t.boolean :customer_contacted, default: false

      t.timestamps
    end
  end
end
