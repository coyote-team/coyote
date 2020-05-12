# frozen_string_literal: true

# @abstract This is the base class for all app models, required for Rails 5
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :by_created_at, -> { order(created_at: :asc) }
  scope :by_id, -> { order(id: :asc) }
  scope :by_creation, -> { by_created_at.by_id }

  def self.first_id(column = :id)
    limit(1).pluck(column).first
  end

  # @return [String] a complete human-readable list of any errors on this object, in sentence form
  def error_sentence
    errors.full_messages.to_sentence
  end

  # @return [String] a more human-readable representation of an ActiveRecord object, simplifies logging
  def to_s
    respond_to?(:name) ? name : "#{self.class.name} #{self[:id]}"
  end
end
