# == Schema Information
#
# Table name: resource_links
#
#  id                  :integer          not null, primary key
#  subject_resource_id :integer          not null
#  verb                :string           not null
#  object_resource_id  :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_resource_links                         (subject_resource_id,verb,object_resource_id) UNIQUE
#  index_resource_links_on_object_resource_id   (object_resource_id)
#  index_resource_links_on_subject_resource_id  (subject_resource_id)
#

class ResourceLink < ApplicationRecord
  belongs_to :subject_resource, :class_name => :Resource, :inverse_of => :subject_resource_links
  belongs_to :object_resource,  :class_name => :Resource, :inverse_of => :object_resource_links

  delegate :organization, :label, :title, :to => :subject_resource, :prefix => true
  delegate :organization, :label, :title, :to => :object_resource, :prefix => true

  validates :verb, presence: true, inclusion: { in: Coyote::ResourceLink::VERB_NAMES, message: "%<value>s is not one of Coyote's accepted verbs: #{Coyote::ResourceLink::VERB_NAMES.to_sentence(last_word_connector: 'or')}" }
  validates_uniqueness_of :verb, scope: %i[subject_resource_id object_resource_id]

  # @return [Symbol] name of the reversed version of this resource link's verb (hasPart vs isPartOf, etc.)
  # @see Coyote::ResourceLink::Verb
  def reverse_verb
    Coyote::ResourceLink::VERBS.fetch(verb.to_sym).reverse_verb_name
  end
end
