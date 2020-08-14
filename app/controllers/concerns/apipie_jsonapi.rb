# frozen_string_literal: true

module ApipieJSONAPI
  def returns_serialized(*args, &block)
    options = args.extract_options!
    options = options.with_indifferent_access
    jsonapi_options = options.slice!(:array_of, :code, :desc)
    array_of = options.delete(:array_of)
    param_group = array_of || args.shift

    if array_of.present?
      returns(*args, options) do
        property array_of.to_s.pluralize, Array, only_in: :response do
          param_group "serialized_#{array_of}"
        end
        instance_exec(&block) if block_given?
      end
    else
      returns("serialized_#{param_group}", options, &block)
    end

    model = send("serializable_#{param_group}")
    example_response = serialize_for_returns(array_of ? Array(model) : model, jsonapi_options)
    example JSON.pretty_generate(example_response)
  end

  def serializes(model, options = {})
    example = serialize_for_returns(model, options)

    def_param_group "serialized_#{model.model_name.i18n_key}" do
      add_param_hash = ->(params) {
        params.each do |key, value|
          if value.respond_to?(:to_hash)
            property key, Hash, only_in: :response do
              instance_exec(value, &add_param_hash)
            end
          elsif value.is_a?(Array)
            property key, Array, only_in: :response, desc: "e.g. #{value.to_json}"
          else
            property key, value.class, only_in: :response, desc: "e.g. #{value.inspect}"
          end
        end
      }
      add_param_hash.call(example)
    end
  end

  private

  def serializable_representation
    Representation.new({
      id:         1,
      author:     User.new(email: "author@example.com"),
      language:   "en",
      license:    License.new(name: "cc0-1.0"),
      metum:      Metum.new(name: "Alt (short)"),
      status:     :approved,
      text:       "Lorem ipsum dolor sit amet",
      created_at: DateTime.now,
      updated_at: DateTime.now,
    })
  end

  def serializable_resource
    Resource.new({
      id:              1,
      organization_id: 1,
      name:            "T.Y.F.F.S.H., 2011",
      canonical_id:    SecureRandom.uuid,
      source_uri:      "https://coyote.pics/wp-content/uploads/2016/02/Screen-Shot-2016-02-29-at-10.05.14-AM-1024x683.png",
      resource_groups: [serializable_resource_group],
      created_at:      DateTime.now,
      updated_at:      DateTime.now,
    })
  end

  def serializable_resource_group
    ResourceGroup.new(
      {
        id:              1,
        organization_id: 1,
        name:            "Paintings",
        webhook_uri:     "https://example.com/webhook/coyote",
      },
    )
  end

  def serialize_for_returns(model, options = {})
    default_render_options = {
      class:  {
        Organization:   SerializableOrganization,
        Representation: SerializableRepresentation,
        Resource:       SerializableResource,
        ResourceGroup:  SerializableResourceGroup,
        User:           SerializableUser,
      },
      expose: {
        url_helpers: Rails.application.routes.url_helpers,
      },
      fields: {
        resource_group:  SerializableResourceGroup::ATTRIBUTES,
        resource_groups: SerializableResourceGroup::ATTRIBUTES,
      },
    }
    JSONAPI::Serializable::Renderer.new.render(model, default_render_options.deep_merge(options))
  end
end
