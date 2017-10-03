RSpec.describe ResourceLink do
  subject { build(:resource_link) }

  it { is_expected.to validate_presence_of(:verb) }
  it { is_expected.to validate_uniqueness_of(:verb).scoped_to(:subject_resource_id,:object_resource_id) } 
  it { is_expected.not_to allow_value('ugh').for(:verb) }
  it { is_expected.to allow_value('hasPart').for(:verb) }

  it { is_expected.to belong_to(:subject_resource).inverse_of(:subject_resource_links) }
  it { is_expected.to belong_to(:object_resource).inverse_of(:object_resource_links) }
end
