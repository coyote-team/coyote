class ScavengerHunt::Time
  attr_reader :seconds

  def initialize(seconds)
    @seconds = seconds
  end

  def +(other_time)
    case other_time
    when ScavengerHunt::Time
      return self.class.new(seconds + other_time.seconds)
    else
      return self.class.new(seconds + other_time)
    end
  end

  def to_s
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
end
