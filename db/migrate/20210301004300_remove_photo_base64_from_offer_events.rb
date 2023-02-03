class RemovePhotoBase64FromOfferEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :offer_events, :photo_base64
  end
end
