# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :status do
    title "Generic"

    factory :ready_to_review_status do
      id Coyote::Statuses::READY_TO_REVIEW
      title "Ready to review"
    end

    factory :approved_status do
      id Coyote::Statuses::APPROVED
      title "Approved"
    end

    factory :not_approved_status do
      id Coyote::Statuses::NOT_APPROVED
      title "Not approved"
    end
  end
end
