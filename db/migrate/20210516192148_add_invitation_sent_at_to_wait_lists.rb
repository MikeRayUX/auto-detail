class AddInvitationSentAtToWaitLists < ActiveRecord::Migration[5.2]
  def change
    add_column :wait_lists, :invite_sent_at, :datetime
  end
end
