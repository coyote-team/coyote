# frozen_string_literal: true

class ScavengerHunt::Time
  attr_reader :seconds

  def initialize(seconds)
    @seconds = seconds
  end

  def +(other)
    case other
    when ScavengerHunt::Time
      self.class.new(seconds + other.seconds)
    else
      self.class.new(seconds + other)
    end
  end

  def to_s
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
end
