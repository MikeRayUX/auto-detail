# Preview all emails at http://localhost:3000/rails/mailers/users/cancelled_new_order
class Users::CancelledNewOrderPreview < ActionMailer::Preview
  def send_email
   
    @user = User.new(
      full_name: Faker::Name.name,
      email: Faker::Internet.email,
      card_brand: 'visa',
      card_last4: '4242'
    )
  
    @order = NewOrder.new(
      ref_code: '324i30i823u4',
      bag_count: 3,
      subtotal: 45,
      tax: 5.55,
      tip: 3,
      grandtotal: 53.55
    )

    @email = Users::CancelledNewOrderMailer.send_email(
      @user,
      @order,
    )
  end
end
