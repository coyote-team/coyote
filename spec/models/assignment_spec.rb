# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  image_id   :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_assignments_on_image_id  (image_id)
#  index_assignments_on_user_id   (user_id)
#

require 'rails_helper'

RSpec.describe Assignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
