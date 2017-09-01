# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string
#  website_id         :integer          not null
#  context_id         :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  canonical_id       :string
#  assignments_count  :integer          default(0), not null
#  descriptions_count :integer          default(0), not null
#  title              :text
#  priority           :boolean          default(FALSE), not null
#  status_code        :integer          default(0), not null
#  old_page_urls      :text
#  organization_id    :integer          not null
#  page_urls          :text             default([]), not null, is an Array
#
# Indexes
#
#  index_images_on_context_id       (context_id)
#  index_images_on_organization_id  (organization_id)
#  index_images_on_website_id       (website_id)
#

RSpec.describe "Image API requests" do
  let(:user) { create(:user,:with_membership) }
  let(:user_organization) { user.organizations.first }
  let(:image ) { create(:image,organization: user_organization) }

  describe 'GET /images/:id.json' do |meta|
    it 'returns image record' do
      get "/images/#{image.id}.json", headers: api_user_headers(user)
      expect_json_keys(%i(id canonical_id  path  page_urls  priority  context_id  website_id  created_at  updated_at url alt title long))
    end
  end

  describe 'GET /images.json' do
    before(:each) do
      @images = []
      5.times do
        image = create(:image)
        @images << image
      end
    end

    it 'returns all image records to user' do
      get "/organizations/#{user_organization.id}/images.json", headers: api_user_headers(user)
      expect_json_keys([:_metadata, :records])
    end
  end
end
