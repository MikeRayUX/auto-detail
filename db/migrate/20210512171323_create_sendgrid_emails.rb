class CreateSendgridEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :sendgrid_emails do |t|
      t.string :template_id
      t.string :description
      t.string :preview_url
      t.text :content_summary
      t.integer :category

      t.timestamps
    end
  end
end