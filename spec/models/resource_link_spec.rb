# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_links
#
#  id                  :bigint           not null, primary key
#  verb                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  object_resource_id  :bigint           not null
#  subject_resource_id :bigint           not null
#
# Indexes
#
#  index_resource_links                         (subject_resource_id,verb,object_resource_id) UNIQUE
#  index_resource_links_on_object_resource_id   (object_resource_id)
#  index_resource_links_on_subject_resource_id  (subject_resource_id)
#
# Foreign Keys
#
#  fk_rails_...  (object_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (subject_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#

RSpec.describe ResourceLink do
  subject { build(:resource_link, :has_version) }

  it { is_expected.to validate_presence_of(:verb) }
  it { is_expected.to validate_uniqueness_of(:verb).scoped_to(:subject_resource_id, :object_resource_id) }
  it { is_expected.not_to allow_value("ugh").for(:verb) }
  it { is_expected.to allow_value("hasPart").for(:verb) }

  it { is_expected.to belong_to(:subject_resource).inverse_of(:subject_resource_links) }
  it { is_expected.to belong_to(:object_resource).inverse_of(:object_resource_links) }

  specify do
    expect(subject.reverse_verb).to eq("isVersionOf")
  end
end
