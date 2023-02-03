class AddPromotionalEmailsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :promotional_emails, :boolean, default: true
  end
end
