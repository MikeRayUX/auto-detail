# == Schema Information
#
# Table name: sendgrid_emails
#
#  id              :bigint           not null, primary key
#  template_id     :string
#  description     :string
#  preview_url     :string
#  content_summary :text
#  category        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe SendgridEmail, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
