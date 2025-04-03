ActsAsTaggableOn.setup do |config|
  config.force_lowercase = true
  config.force_parameterize = true
  config.remove_unused_tags = true
  config.default_parser = ActsAsTaggableOn::GenericParser
end

ActsAsTaggableOn::Tagging.class_eval do
  default_scope { where(tenant: Current.organization&.id&.to_s) }
end
