# == Schema Information
#
# Table name: meta
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  instructions :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe Metum, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
