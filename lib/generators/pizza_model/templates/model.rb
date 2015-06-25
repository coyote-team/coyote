<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>

<% if options[:attachments] -%>
  include HasAttachments
<% end -%>
<% if options[:sortable] -%>
  include RankedModel
  ranks :place

  def self.default_scope
    self.rank(:place)
  end
<% end -%>
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>
end
<% end -%>
