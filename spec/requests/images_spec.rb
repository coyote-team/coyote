# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string(255)
#  website_id         :integer
#  group_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  canonical_id       :string(255)
#  assignments_count  :integer          default(0)
#  descriptions_count :integer          default(0)
#  title              :text(65535)
#  priority           :boolean          default(FALSE)
#  status_code        :integer          default(0)
#  page_urls          :text(65535)
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

require 'spec_helper'

describe 'GET /images/:id.json' do
  before(:each) do
    @user = create(:user)
    @image = create(:image)
  end
  it 'returns image record' do
    get "/images/#{@image.id}.json", {}.to_json, set_headers(@user)
    #expect(response_json).to eq(image_json)
    expect_json_keys(	:id, 
											:canonical_id, 
											:path, 
											:page_urls, 
											:priority, 
											:group_id, 
											:website_id, 
											:created_at, 
											:updated_at,
											:url,
											:alt,
											:title,
											:long
                    )
  end
end

describe 'GET /images.json' do
  #optional params: page, canonical_id, status_ids, priority
  #Default is [2] for the public view.
  before(:each) do
    @user = create(:user)
    @images = []
    5.times do
      image = create(:image)
      @images << image
    end
  end
  it 'returns all image records to user' do
    @user = create(:user)
    get "/images.json", {}.to_json, set_headers(@user)
    #expect(response_json).to eq(images_json(@images))
    expect_json_keys([:_metadata, :records])
  end
end

#describe 'POST /api/v1/images' do
  #it 'returns error if validations fail' do
    #@user = create(:user)
    #post "/api/v1/images/", {"" => ""}.to_json, set_headers(@user.authentication_token)
    #expect(response_json).to eq({
      #'message' => 'Validation Failed',
      #'errors' => [
        #"",        
        #]
      #})
  #end
#end

#describe 'PATCH /api/v1/images/:id' do
  #before(:each) do
    #@image = create(:image)
  #end
  #it 'updates image attributes' do
    #@admin = create(:admin)
    #patch "/api/v1/images/#{@image.id}", image_json(page_urls: "").to_json, set_headers(@admin.authentication_token)
    #expect(response_json).to eq({
      #"id" => @image.id
      #})
  #end
#end

#describe 'DELETE /api/v1/images/:id' do
  #before(:each) do
    #@image = create(:image)
  #end
  #it 'destroys image if user is :admin' do
    #@admin = create(:admin)
    #delete "/api/v1/images/#{@image.id}", {}, set_headers(@admin.authentication_token)
    #expect(response_json).to eq({ "message" => "Image deleted."})
  #end
  ## it 'does not destroy image if user not authenticated' do
  ##   delete "/api/v1/images/#{@image.id}"
  ##   expect(response_json).to eq({ "message" => "Forbidden"})  
  ## end    
#end

def images_json(images)
  @images = []
  images.each do |image|
      @image = image
      @images << image_json
    end
  @images
end

#def image_json(opts = {})
  #hash = {
    #id: opts[:id] || @image.id,
    #canonical_id: "",
    #created_at: opts[:created_at] || @image.created_at.strftime('%FT%T.%LZ'),
    #updated_at: opts[:updated_at] || @image.updated_at.strftime('%FT%T.%LZ'),
    #}.as_json
#end
