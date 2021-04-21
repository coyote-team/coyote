# frozen_string_literal: true

# @abstract This is the base class for all app models, required for Rails 5
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :by_created_at, ->(direction = :asc) { order(created_at: direction) }
  scope :by_id, ->(direction = :asc) { order(id: direction) }
  scope :by_creation, ->(direction = :asc) { by_created_at(direction).by_id(direction) }

  def self.enum(definitions)
    definitions.each do |attribute, values|
      super attribute => values

      decorate_attribute_type(attribute, :enum) do |subtype|
        FriendlyEnumType.new(attribute, public_send(attribute.to_s.pluralize), subtype)
      end

      validates attribute, inclusion: {in: values.keys.map(&:to_sym) + values.keys.map(&:to_s) + values.values}
    end
  end

  def self.first_id(column = :id)
    limit(1).pick(column)
  end

  def self.human_name(capitalize: true, count: 1)
    model_name.human(count: count).humanize(capitalize: capitalize)
  end

  def default_name
    "#{model_name} ##{id}"
  end

  # @return [String] a complete human-readable list of any errors on this object, in sentence form
  def error_sentence
    errors.full_messages.to_sentence
  end

  # @return [String] a more human-readable representation of an ActiveRecord object, simplifies logging
  def to_s
    respond_to?(:name) && name.presence || default_name
  end

  private

  class FriendlyEnumType < ActiveRecord::Enum::EnumType
    # suppress <ArgumentError>
    # returns a value to be able to use +inclusion+ validation
    def assert_valid_value(value)
      value
    end
  end
end
