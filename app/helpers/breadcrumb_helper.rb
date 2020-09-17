# frozen_string_literal: true

module BreadcrumbHelper
  def breadcrumb(*args)
    arrow = safe_join([" ", icon(:arrow_right), " "])
    final = args.pop

    crumbs = args.map { |crumb|
      [link_to(crumb, crumb), arrow]
    }.flatten
    crumbs.push(final)

    safe_join(crumbs)
  end
end
