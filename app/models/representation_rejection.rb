# == Schema Information
#
# Table name: representation_rejections
#
#  id                :bigint           not null, primary key
#  reason            :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representation_id :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_representation_rejections_on_representation_id  (representation_id)
#  index_representation_rejections_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (representation_id => representations.id)
#  fk_rails_...  (user_id => users.id)
#
class RepresentationRejection < ApplicationRecord
  belongs_to :representation
  belongs_to :user

  validates :reason, presence: true
end
