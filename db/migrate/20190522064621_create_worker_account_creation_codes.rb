# frozen_string_literal: true

class CreateWorkerAccountCreationCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :worker_account_creation_codes do |t|
      t.string :code
      t.timestamps
    end
  end
end
