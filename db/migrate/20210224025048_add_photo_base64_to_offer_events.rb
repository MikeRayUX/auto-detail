class AddPhotoBase64ToOfferEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :offer_events, :photo_base64, :string
  end
end
