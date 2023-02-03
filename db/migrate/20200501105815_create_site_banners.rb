class CreateSiteBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :site_banners do |t|
      t.integer :display_location
      t.string :body_text
      t.string :link_text
      t.string :link_url
      t.string :alt_url
      t.string :conditional

      t.timestamps
    end
  end
end
