# Preview all emails at http://localhost:3001/rails/mailers/commercial/new_client
class Commercial::NewClientPreview < ActionMailer::Preview
  def send_email
    @client = Client.new(
      name: 'acme salon',
      phone: '5555555555',
      email: 'acmesalon@sample.com',
      special_notes: 'nothing here',
      contact_person: 'adam smith',
      area_of_business: 'nail salon',
      monday: true,
      tuesday: true,
      wednesday: true,
      thursday: true,
      friday: true,
      saturday: false,
      sunday: false,
      pickup_window: 'afternoon',
      price_per_pound: 1.49,
    )

    @address = @client.build_address(
      unit_number: '12',
      city: 'seattle',
      state: 'wa',
      zipcode: '98168',
      street_address: '1234 sample st',
      pick_up_directions: 'around back'
    )

    Commercial::NewClientMailer.send_email(@client)
  end

end
