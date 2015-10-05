require 'roo'
#
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
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

class Image < ActiveRecord::Base
  acts_as_taggable_on :tags

  belongs_to :website
  belongs_to :group

  has_many :descriptions, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  validates :path, :presence => true, :uniqueness => {:scope => :website_id}
  validates :canonical_id, :presence => true, :uniqueness => {:scope => :website_id}
  validates_associated :website, :group
  validates_presence_of :website, :group

  default_scope {order('created_at DESC')}

  scope :unassigned, -> (n = 0) { select { |i| i.assignments_count == n } }
  scope :undescribed, -> (n = 0) { select { |i| i.descriptions_count == n } }
  scope :assigned, -> (n = 0) { select { |i| i.assignments_count > n } }

  paginates_per 50

  def to_s
    path
  end

  def alt(status_ids=[2])
    d = descriptions.where(metum_id: 1, status_id: status_ids, locale: "en").first
    if d
      d.text
    else
      ""
    end
  end

  def long(status_ids=[2])
    d = descriptions.where(metum_id: 3, status_id: status_ids, locale: "en").first
    if d
      d.text 
    else
      ""
    end
  end

  def url
    if website
      website.url + path
    end
  end

  def title
    require 'multi_json'
    require 'open-uri'

    title = Rails.cache.fetch([self, 'title'].hash, expires_in: 1.minute) do
      title = ""
      if self.website.url.include?("mcachicago")
        url = "https://cms.mcachicago.org/api/v1/attachment_images/" + self.canonical_id
        Rails.logger.info "grabbing image json at #{url}"

        begin
          content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, read_timeout: 5}).read
        rescue OpenURI::HTTPError => error
          response = error.io
          Rails.logger.error response.string
          length = 0
        end

        begin 
          image = JSON.parse(content)
        rescue Exception => e
          Rails.logger.error "JSON parsing exception"
          Rails.logger.error e
          length = 0
        end
        title = image["title"]
      end
      title
    end
    title
  end

  #has no descriptions by this user in any locale
  def undescribed_by?(user)
    !descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #has 1 of description by this user in any locale
  def described_by?(user)
   descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #has 1 of each metum by this user in any combo of locales and status'es
  def completed_by?(user)
    meta_ids = Metum.all.map{|m| m.id}
    described_meta_ids = descriptions.collect{ |d| d.metum_id if d.user_id == user.id}.compact 
    (meta_ids - described_meta_ids).empty?
  end

  #completed all meta in any combo of locales
  def completed?
    meta_ids = Metum.all.map{|m| m.id}
    #approved_id = Status.find_by_title("Approved")
    #if (meta_ids - descriptions.where({status_id: approved_id}).map{|d| d.metum_id unless d.nil?}).empty?
    if (meta_ids - descriptions.map{|d| d.metum_id unless d.nil?}).empty?
      true
    else
      false
    end
  end

  def status
    if partially_completed? 
      if completed?
        if ready_to_review?
          return "Ready to Review" 
        else
          return "Completed" 
        end
      else
        return "Partially Completed"
      end
    else
      return "Not described"
    end
  end

  def partially_completed?
    #approved_id = Status.find_by_title("Approved")
    #descriptions.where({status_id: approved_id}).count > 0
    descriptions.count > 0
  end

  def ready_to_review?
    ready_id = Status.find_by_title("Ready to review")
    if descriptions.where({status_id: ready_id}).size > 0
      true
    end
  end

  def not_approved?
    not_approved_id = Status.find_by_title("Not approved")
    if descriptions.where({status_id: not_approved_id}).size > 0
      true
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    puts "YAML:"
    puts spreadsheet.to_yaml #DEBUG
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      image = find_by_id(row["id"]) || new
      #image.attributes = row.to_hash.slice(*accessible_attributes)
      image.attributes = row.to_hash
      image.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.pat)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
end
