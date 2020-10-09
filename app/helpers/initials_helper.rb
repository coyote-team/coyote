module InitialsHelper
  def initials(name)
    scanner = StringScanner.new(name.to_s)
    words = []
    while (word = scanner.scan_until(/[^a-z0-9.-]/))
      words.push(*split_word_into_initials(word))
    end

    words.push(*split_word_into_initials(scanner.rest)) if scanner.rest?

    safe_join(words)
  end

  def split_word_into_initials(word)
    if word.length > 1
      [
        tag.span(word.first, class: "initial"),
        tag.span(word[1..-1], class: "initial initial--collapse"),
      ]
    else
      [
        tag.span(word, class: "initial initial--collapse"),
      ]
    end
  end
end
