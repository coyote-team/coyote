require 'roo'
#
# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  website_id :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_images_on_website_id  (website_id)
#

class Image < ActiveRecord::Base
  belongs_to :website
  has_many :descriptions, dependent: :destroy

  validates :url, :presence => true, :uniqueness => {:scope => :website_id}
  validates_associated :website

  def to_s
    url
  end

  def full_url
    if website
      website.url + url
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
