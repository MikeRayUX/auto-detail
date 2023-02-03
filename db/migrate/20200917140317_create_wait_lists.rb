class CreateWaitLists < ActiveRecord::Migration[5.2]
  def change
    create_table :wait_lists do |t|
      t.string :zipcode
      t.index :zipcode
      t.string :email

      t.timestamps
    end
  end
end
