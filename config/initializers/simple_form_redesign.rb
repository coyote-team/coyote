# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.button_class = 'button button--default'
  config.default_form_class = 'form'
  config.error_notification_class = 'notification notification--error notification-title'

  config.wrappers :default, class: 'form-field', error_class: 'form-field--error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'form-field-label label--stack'

    b.use :label_input
    b.use :error, wrap_with: { class: 'form-field-error-message' }
    b.use :hint,  wrap_with: { class: 'form-field-hint' }
  end

  config.wrappers :filter_set, class: 'filter-set-item', error_class: 'form-field--error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'filter-set-item-title'

    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'form-field-error-message' }
    b.use :hint,  wrap_with: { class: 'form-field-hint' }
  end

  config.wrappers :inline, error_class: 'form-field--error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.optional :label

    b.use :input

    b.optional :error, wrap_with: { class: 'form-field-error-message' }
    b.optional :hint,  wrap_with: { class: 'form-field-hint' }
  end

  config.default_wrapper = :default
end