# frozen_string_literal: true

module TabHelper
  def tab(label, options = {}, &block)
    # Set up some references between the tab and its pane
    active = options.delete(:active).present?
    pane_id = "#{@tabset_id}-pane-#{@tab_index}"
    tab_id = "#{@tabset_id}-tab-#{@tab_index}"

    # Prepare to render the pane using the block we received
    options[:aria] ||= {}
    options[:aria][:labelledby] = tab_id
    options[:class] = ["tab-content"].push(Array(options[:class]))
    options[:hidden] = !active
    options[:id] = pane_id
    options[:role] = "tabpanel"
    options[:tabindex] = active ? "0" : "-1"

    # Push the pane content onto the tab buffer
    @tab_buffer.push(tag.div(capture(&block), options))

    # Return the tab item
    tab_options = {
      aria:     {
        controls: pane_id,
        selected: active,
      },
      class:    "tab",
      id:       tab_id,
      role:     "tab",
      tabindex: active ? "0" : "-1",
      type:     :button,
    }

    tag.button(label, tab_options)
  ensure
    @tab_index += 1
  end

  def tabs(options = {}, &block)
    # Cache any parent tabset config
    original_tabset_id = @tabset_id
    original_tab_index = @tab_index
    original_tab_buffer = @tab_buffer

    # Set up a new tabset
    @tabset_id = options[:id].presence || generate_id
    @tab_index = 0
    @tab_buffer = []

    # Run the block - it will generate HTML, and if `tab` is called within it, that tab will be
    # output in HTML and its pane content added to the buffer
    tabs = capture(&block)

    # Set up some sane defaults for the tab list
    options[:aria] ||= {}
    options[:aria][:label] = options.delete(:label)
    options[:role] = "tablist"
    options[:class] = ["tabs"].push(options[:class])

    # Concatenate the tab list and the buffer panes
    safe_join([
      tag.div(tabs, options),
      *@tab_buffer,
    ])
  ensure
    # Restore the cached values
    @tabset_id = original_tabset_id
    @tab_index = original_tab_index
    @tab_buffer = original_tab_buffer
  end
end
