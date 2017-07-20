class ActiveRecord::Base
  # @return [String] a more human-readable representation of an ActiveRecord object, simplifies logging
  def to_s
    "#{self.class.name} #{self[:id]}"
  end
end
