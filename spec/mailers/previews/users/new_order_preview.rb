# Preview all emails at http://localhost:3001/rails/mailers/users/new_order

class Users::NewOrderPreview < ActionMailer::Preview
  def send_email
    @region = Region.new(
      tax_rate: 0.101
    )

    @user = User.new(
      full_name: Faker::Name.name,
      email: Faker::Internet.email,
      card_brand: 'visa',
      card_last4: '4242'
    )

    @address = Address.new(
      street_address: '1233 s 117th st',
      unit_number: '12A',
      city: 'Seattle',
      state: 'Washington',
      zipcode: '98168'
    )
    @order = NewOrder.new(
      ref_code: '324i30i823u4',
      bag_count: 3,
      subtotal: 45,
      tax: 5.55,
      tip: 3,
      grandtotal: 53.55
    )

    @email = Users::NewOrderMailer.send_email(
      @region,
      @user,
      @address, 
      @order,
    )
  end
end
