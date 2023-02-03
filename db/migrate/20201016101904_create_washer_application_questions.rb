class CreateWasherApplicationQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :washer_application_questions do |t|
      t.string :question

      t.timestamps
    end
  end
end
