# frozen_string_literal: true

class CreateQuestionaires < ActiveRecord::Migration[5.2]
  def change
    create_table :questionaires do |t|
      t.belongs_to :user
      t.integer :subject
      t.string :answer_selection
      t.string :elaboration

      t.timestamps
    end
  end
end
