require 'roo'
require 'csv'

#
# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string
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
#

class Image < ApplicationRecord
  acts_as_taggable_on :tags

  before_validation :update_status_code

  belongs_to :context, touch: true, :inverse_of => :images
  belongs_to :organization, :inverse_of => :images, optional: true

  has_many :descriptions, :dependent => :destroy
  has_many :assignments, :inverse_of => :image, :dependent => :destroy
  has_many :users, through: :assignments

  validates :path, :presence => true
  validates :canonical_id, :presence => true
  validates_associated :context

  audited

  scope :described,              -> { joins(:descriptions) }
  scope :assigned,               -> { joins(:assignments) }
  scope :unassigned,             -> { left_outer_joins(:assignments).where(assignments: { image_id: nil }) }
  scope :undescribed,            -> { left_outer_joins(:descriptions).where(descriptions: { image_id: nil }) }
  scope :assigned_undescribed,   -> { undescribed.joins(:assignments) }
  scope :unassigned_undescribed, -> { undescribed.left_outer_joins(:assignments).where(assignments: { image_id: nil }) }
  scope :prioritized,            -> { order(:priority => :desc, :created_at => :desc) }

  paginates_per 50

  # @return [ActiveSupport::TimeWithZone] if one more images exist, this is the created_at time for the most recently-created image
  # @return [nil] if no images exist
  def self.latest_timestamp
    order(:created_at).last.try(:created_at)
  end

  def to_s
    path
  end

  #TODO are these both the most recent? c.f. apipie doc in images#index
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

  def is_mca?
    true
  end

  def url(protocol="https:")
    if path.starts_with?("//")
      protocol + path
    elsif path.starts_with?("http")
      path
    else 
      path
    end
  end

  #TODO per locale
  #has no descriptions by this user 
  def undescribed_by?(user)
    !descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #has 1 of description by this user
  def described_by?(user)
   descriptions.collect{ |d| d.user_id}.compact.include?(user.id)
  end

  #TODO consider locale
  #has 1 of each metum by this user  ? in any combo of locales and status'es
  def completed_by?(user)
    meta_ids = Metum.all.map{|m| m.id}
    described_meta_ids = descriptions.collect{ |d| d.metum_id if d.user_id == user.id}.compact 
    (meta_ids - described_meta_ids).empty?
  end

  def status
    case status_code
    when 0
      "Not Described"
    when 1
      "Partially Completed"
    when 2
      "Ready to Review" 
    when 3
      "Completed" 
    else
      return "Not Described"
    end
  end

  def begun?
    descriptions.begun.count > 0
  end

  def ready_to_review?
    descriptions.ready_to_review.count > 0
  end

  #completed all meta in any combo of locales
  def completed?
    meta_ids = Metum.all.map{|m| m.id}
    if meta_ids.count == descriptions.approved.map{|d| d.metum_id unless d.nil?}.uniq.compact.count
      true
    else
      false
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      image = find_by_id(row["id"]) || new
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

  def update_status_code
    if begun? 
      if completed?
        self.status_code = 3
      elsif ready_to_review?
        self.status_code = 2
      else
        self.status_code = 1
      end
    else
      self.status_code = 0
    end

    return true
  end
end
