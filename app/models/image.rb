require 'roo'
#
# == Schema Information
#
# Table name: images
#
#  id           :integer          not null, primary key
#  path         :string(255)
#  website_id   :integer
#  group_id     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  canonical_id :string(255)
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

  scope :unassigned, -> (n = 0) { select { |i| i.users.size == n } }
  scope :assigned, -> (n = 0) { select { |i| i.users.size > n } }

  paginates_per 50

  def to_s
    path
  end

  def url
    if website
      website.url + path
    end
  end

  #has no descriptions by this user in any locale
  def undescribed_by?(user)
    !descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #has 1 of description by this user in any locale
  def described_by?(user)
   descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #has 1 of each metum by this user in any combo of locales
  def completed_by?(user)
    meta_ids = Metum.all.map{|m| m.id}
    described_meta_ids = descriptions.collect{ |d| d.metum_id if d.user_id == user.id}.compact 
    (meta_ids - described_meta_ids).empty?
  end

  #TODO has 1 of description by this user in any combo of locales but hasn't been completed
  def described_but_not_completed_by?(user)
  end

  #completed all meta in any combo of locales
  def completed?
    meta_ids = Metum.all.map{|m| m.id}
    approved_id = Status.find_by_title("Approved")
    if (meta_ids - descriptions.where({status_id: approved_id}).map{|d| d.metum_id unless d.nil?}).empty?
      true
    else
      false
    end
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
