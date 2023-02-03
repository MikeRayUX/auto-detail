class ChangeProblemEncounteredForCourierProblems < ActiveRecord::Migration[5.2]
  def change
    remove_column :courier_problems, :problem_encountered
    
    add_column :courier_problems, :problem_encountered, :integer
  end
end
