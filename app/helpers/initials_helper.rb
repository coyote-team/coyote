# frozen_string_literal: true

module InitialsHelper
  def initials(name)
    scanner = StringScanner.new(name.to_s)
    words = []
    while (word = scanner.scan_until(/[^a-z0-9.-]/))
      words.push(*split_word_into_initials(word, words.length))
    end

    words.push(*split_word_into_initials(scanner.rest, words.length, rest: true)) if scanner.rest?

    safe_join(words)
  end

  def split_word_into_initials(word, index, rest: false)
    if rest
      [
        tag.span(word, class: "initial initial--collapse"),
      ]
    elsif word.length > 1
      [
        tag.span(word.first, class: "initial"),
        tag.span(word[1..-1], class: "initial initial--collapse"),
      ]
    elsif index.zero?
      [
        tag.span(word, class: "initial"),
      ]
    else
      [
        tag.span(word, class: "initial initial--collapse"),
      ]
    end
  end
end
