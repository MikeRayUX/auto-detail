class GeocodeAllExistingAddresses < ActiveRecord::Migration[5.2]
  def change
    # washers migration
    ActiveRecord::Base.transaction do
      @addresses = Address.where(latitude: nil)

      if @addresses.any?
        @addresses.each do |a|
          a.geocode

          if a.save
          p "Address geocoded successfully"
          p "address: #{a.id} updated_successfully!"
          else
            p "Address geocode FAILED"
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end
end
