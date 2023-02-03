class Users::MissingBagsMailer < ApplicationMailer
  def send_email(new_order, user, old_bag_count, missing_bags_count)
    @new_order, @user, @old_bag_count, @missing_bags_count = new_order, user, old_bag_count, missing_bags_count

    mail(
      to: user.email,
      subject: 'Uh oh! There was a issue with your order | FreshAndTumble',
      from: 'no-reply@freshandtumble.com'
    )
  end
end
