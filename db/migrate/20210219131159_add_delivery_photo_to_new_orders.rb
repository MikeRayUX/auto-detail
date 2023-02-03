class AddDeliveryPhotoToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :delivery_photo_base64, :string
  end
end
