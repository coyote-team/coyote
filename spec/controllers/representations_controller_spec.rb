# == Schema Information
#
# Table name: representations
#
#  id           :integer          not null, primary key
#  resource_id  :integer          not null
#  text         :text
#  content_uri  :string
#  status       :enum             default("ready_to_review"), not null
#  metum_id     :integer          not null
#  author_id    :integer          not null
#  content_type :string           default("text/plain"), not null
#  language     :string           not null
#  license_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#

RSpec.describe RepresentationsController do
  pending
end
