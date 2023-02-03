class AddLeftBusinessReviewToUsers < ActiveRecord::Migration[5.2]
	def change
		add_column :users, :business_review_left, :boolean, default: false
  end
end
