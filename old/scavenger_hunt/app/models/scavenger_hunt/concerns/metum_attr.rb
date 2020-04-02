# frozen_string_literal: true

module MetumAttr
  def metum_attr(resource, metum_name)
    resource.representations.approved.with_metum_named(metum_name).first&.text
  end
end
