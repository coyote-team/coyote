# == Schema Information
#
# Table name: representations
#
#  id           :bigint(8)        not null, primary key
#  resource_id  :bigint(8)        not null
#  text         :text
#  content_uri  :string
#  status       :enum             default("ready_to_review"), not null
#  metum_id     :bigint(8)        not null
#  author_id    :bigint(8)        not null
#  content_type :string           default("text/plain"), not null
#  language     :string           not null
#  license_id   :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  notes        :text
#  endpoint_id  :bigint(8)        not null
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_endpoint_id  (endpoint_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#

RSpec.describe Representation do
  subject { build(:representation) }

  it { is_expected.to validate_presence_of(:language) }

  context 'with text and content URI blank' do
    subject do
      build(:representation, text: '', content_uri: '').tap(&:valid?)
    end

    specify do
      expect(subject.errors[:text]).to be_present
    end
  end
end
