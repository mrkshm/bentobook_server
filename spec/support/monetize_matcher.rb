RSpec::Matchers.define :monetize do |money_attribute|
  match do |model|
    model.class.monetized_attributes.keys.include?(money_attribute.to_s)
  end

  chain :allow_nil do
    @allow_nil = true
  end

  description do
    "monetize :#{money_attribute}"
  end

  failure_message do |model|
    "Expected #{model.class.name} to monetize :#{money_attribute}"
  end
end
