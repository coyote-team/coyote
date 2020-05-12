# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_links
#
#  id                  :bigint           not null, primary key
#  verb                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  object_resource_id  :bigint           not null
#  subject_resource_id :bigint           not null
#
# Indexes
#
#  index_resource_links                         (subject_resource_id,verb,object_resource_id) UNIQUE
#  index_resource_links_on_object_resource_id   (object_resource_id)
#  index_resource_links_on_subject_resource_id  (subject_resource_id)
#
# Foreign Keys
#
#  fk_rails_...  (object_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (subject_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#

class ResourceLink < ApplicationRecord
  belongs_to :subject_resource, class_name: :Resource, inverse_of: :subject_resource_links
  belongs_to :object_resource, class_name: :Resource, inverse_of: :object_resource_links

  delegate :organization, :label, :name, to: :subject_resource, prefix: true
  delegate :organization, :label, :name, to: :object_resource, prefix: true

  validates :verb, presence: true, inclusion: {in: Coyote::ResourceLink::VERB_NAMES, message: "%<value>s is not one of Coyote's accepted verbs: #{Coyote::ResourceLink::VERB_NAMES.to_sentence(last_word_connector: "or")}"}
  validates :verb, uniqueness: {scope: %i[subject_resource_id object_resource_id]}

  audited

  # @return [String] name of the reversed version of this resource link's verb (hasPart vs isPartOf, etc.)
  # @see Coyote::ResourceLink::Verb
  def reverse_verb
    Coyote::ResourceLink::VERBS.fetch(verb.to_sym).reverse_verb_name.to_s
  end
end
