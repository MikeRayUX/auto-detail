class CreateRegions < ActiveRecord::Migration[5.2]
  def change
		create_table :regions do |t|
			t.string :area
			t.float :tax_rate

      t.timestamps
    end
  end
end
