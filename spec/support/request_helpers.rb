module RequestHelpers
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :controller
  config.include RequestHelpers, type: :request
end
