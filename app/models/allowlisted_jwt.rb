# == Schema Information
#
# Table name: allowlisted_jwts
#
#  id         :bigint           not null, primary key
#  aud        :string
#  exp        :datetime
#  jti        :string           not null
#  metadata   :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_allowlisted_jwts_on_aud_and_jti  (aud,jti)
#  index_allowlisted_jwts_on_exp          (exp)
#  index_allowlisted_jwts_on_jti          (jti) UNIQUE
#  index_allowlisted_jwts_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class AllowlistedJwt < ApplicationRecord
  belongs_to :user
end
