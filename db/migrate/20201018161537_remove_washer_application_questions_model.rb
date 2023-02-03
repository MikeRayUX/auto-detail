class RemoveWasherApplicationQuestionsModel < ActiveRecord::Migration[5.2]
  def change
    drop_table :washer_application_questions
  end
end
