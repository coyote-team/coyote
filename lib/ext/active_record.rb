ActiveRecord::Base.class_eval do
  # @return [String] a more human-readable representation of an ActiveRecord object, simplifies logging
  def to_s
    "#{self.class.name} #{self[:id]}"
  end

  # @return [String] a complete human-readable list of any errors on this object, in sentence form
  def error_sentence
    errors.full_messages.to_sentence
  end
end
