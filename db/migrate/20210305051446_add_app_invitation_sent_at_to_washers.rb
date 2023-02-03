class AddAppInvitationSentAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :app_invitation_sent_at, :datetime
  end
end
