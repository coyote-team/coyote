module TitleHelper
  # Returns a title tag if a 'title' option is present. Also modifies options
  # to point to the title tag as `aria-labelledby`.
  def title_for(options = {})
    title = options.delete(:title)
    return "".html_safe unless title.present?

    case title
    when Hash
      tag = title.fetch(:tag, :h2)
      title = title[:text]
    when String
      tag = :h2
    end

    id = id_for(title)
    options[:aria] = combine_options(options[:aria] || {}, labelled_by: id)
    content_tag(tag, class: 'sr-only', id: id) { title }
  end
end
