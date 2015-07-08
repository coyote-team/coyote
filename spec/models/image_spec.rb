# == Schema Information
#
# Table name: images
#
#  id           :integer          not null, primary key
#  url          :string(255)
#  website_id   :integer
#  group_id     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  canonical_id :string(255)
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

require 'rails_helper'

RSpec.describe Image, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
