# frozen_string_literal: true

module Coyote
  # Utilities for managing ResourceLinks
  module ResourceLink
    # Basic container for Coyote Verb definitions
    Verb = Struct.new(:name, :description, :reverse) {
      def reverse_verb_name
        reverse.name
      end
    }

    # Various kinds of verbs we support form forming subject-verb-object predicate among Resources
    # @see Verb
    # @see VERBS
    # @see http://dublincore.org/documents/dcmi-terms/
    VERB_PAIRS = [
      [Verb.new(:hasPart, "a related resource that is included either physically or logically in the described resource."),
       Verb.new(:isPartOf, "a related resource in which the described resource is physically or logically included.")],

      [Verb.new(:hasVersion, "a related resource that is a version, edition, or adaptation of the described resource."),
       Verb.new(:isVersionOf, "a related resource of which the described resource is a version, edition, or adaptation.")],

      [Verb.new(:hasFormat, "a related resource that is substantially the same as the pre-existing described resource, but in another format."),
       Verb.new(:isFormatOf, "a related resource that is substantially the same as the described resource, but in another format.")],

      [Verb.new(:references, "a related resource that is referenced, cited, or otherwise pointed to by the described resource."),
       Verb.new(:isReferenceBy, "a related resource that references, cites, or otherwise points to the described resource.")],

      [Verb.new(:hasSameIdentity, "a related resource that is identical to the described resource."),
       Verb.new(:isIdenticalTo, "a related resource that is identical to the described resource.")],
    ].freeze

    # Lookup table for verbs
    # @see Verb
    # @see VERB_PAIRS
    VERBS = VERB_PAIRS.inject({}) { |result, (forward_relation, backward_relation)|
      forward_relation.reverse = backward_relation
      backward_relation.reverse = forward_relation

      result.merge!({
        forward_relation.name  => forward_relation,
        backward_relation.name => backward_relation,
      })
    }.freeze

    VERB_CHOICES = VERB_PAIRS.inject([]) { |total, (forward, reverse)|
      total << ["#{forward.name} (#{forward.description})", forward.name]
      total << ["#{reverse.name} (#{reverse.description})", reverse.name]
    }.freeze

    VERB_NAMES = VERB_PAIRS.flatten.map { |v| v.name.to_s }.freeze
  end
end
