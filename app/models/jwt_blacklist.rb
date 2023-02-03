# == Schema Information
#
# Table name: jwt_blacklists
#
#  id         :bigint           not null, primary key
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class JwtBlacklist < ApplicationRecord
  validates :jti, presence: true
end
