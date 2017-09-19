# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  instructions    :text             default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_meta_on_organization_id            (organization_id)
#  index_meta_on_organization_id_and_title  (organization_id,title) UNIQUE
#

RSpec.describe MetaController do
  skip 'TODO'
end
