# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id                :bigint           not null, primary key
#  changed_records   :integer          default(0), not null
#  duplicate_records :integer          default(0), not null
#  error             :string
#  failures          :integer          default(0), not null
#  new_records       :integer          default(0), not null
#  sheet_mappings    :json
#  status            :integer          default("parsing"), not null
#  successes         :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_imports_on_organization_id  (organization_id)
#  index_imports_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :import do
    spreadsheet { File.open(Rails.root.join("spec", "fixtures")) }
  end
end
