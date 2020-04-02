# frozen_string_literal: true

class ScavengerHunt::Answer < ScavengerHunt::ApplicationRecord
  before_create :set_is_correct

  belongs_to :clue

  scope :is_correct, -> { where(is_correct: true) }

  private

  def clean(text)
    text.downcase.gsub(/[^a-z0-9]/, "")
  end

  def in_words(int)
    numbers_to_name = {
      1000000 => "million",
      1000    => "thousand",
      100     => "hundred",
      90      => "ninety",
      80      => "eighty",
      70      => "seventy",
      60      => "sixty",
      50      => "fifty",
      40      => "forty",
      30      => "thirty",
      20      => "twenty",
      19      => "nineteen",
      18      => "eighteen",
      17      => "seventeen",
      16      => "sixteen",
      15      => "fifteen",
      14      => "fourteen",
      13      => "thirteen",
      12      => "twelve",
      11      => "eleven",
      10      => "ten",
      9       => "nine",
      8       => "eight",
      7       => "seven",
      6       => "six",
      5       => "five",
      4       => "four",
      3       => "three",
      2       => "two",
      1       => "one",
    }
    str = ""

    numbers_to_name.each do |num, name|
      if int == 0
        return str
      elsif int.to_s.length == 1 && int / num > 0
        return str + name.to_s
      elsif int < 100 && int / num > 0
        return str + name.to_s if int % num == 0
        return str + "#{name} " + in_words(int % num)
      elsif int / num > 0
        return str + in_words(int / num) + " #{name} " + in_words(int % num)
      end
    end
  end

  def set_is_correct
    self.is_correct = clean(answer) == clean(clue.answer) || clean(in_words(clue.answer.to_i)) == clean(answer)
    clue.touch(:ended_at) if is_correct?
    true
  end
end
