class CreateEmailSends < ActiveRecord::Migration[5.2]
  def change
    create_table :email_sends do |t|
      t.belongs_to :user
      t.belongs_to :washer
      t.belongs_to :sendgrid_email

      t.integer :status
      t.string :api_errors
      t.timestamps
    end
  end
end
