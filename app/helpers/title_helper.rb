module TitleHelper
  # Returns a title tag if a 'title' option is present. Also modifies options
  # to point to the title tag as `aria-labelledby`.
  def title_for(options = {})
    title = options.delete(:title)
    return "".html_safe unless title.present?

    case title
    when Hash
      title_options = title
      title = title[:text]
    when String
      title_options = {}
    end

    tag = title_options.fetch(:tag, :h2)
    sr_only = title_options.key?(:sr_only) ? title_options.delete(:sr_only) : true

    id = id_for(title)

    # Update the options hash so that subsequent uses include the label
    combine_options(options, aria: { labelledby: id })

    # Configure the title tag
    title_options = combine_options(title_options, { class: sr_only ? 'sr-only' : nil, id: id })
    content_tag(tag, title_options) { title }
  end
end
