# frozen_string_literal: true

class SerializableActiveModelErrors
  def initialize(exposures)
    @errors = exposures[:object]
    @reverse_mapping = exposures[:_jsonapi_pointers] || {}

    freeze
  end

  def as_jsonapi
    @errors.keys.flat_map do |key|
      @errors.full_messages_for(key).map do |message|
        Error.new(field: key, message: message,
                                          pointer: @reverse_mapping[key])
          .as_jsonapi
      end
    end
  end

  private

  class Error < JSONAPI::Serializable::Error
    title do
      "Invalid #{@field}" if @field.present? && @field != :base
    end

    detail do
      @message
    end

    source do
      pointer @pointer unless @pointer.nil?
    end
  end
end
