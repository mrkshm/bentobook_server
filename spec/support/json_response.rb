module JsonResponse
  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonResponse, type: :request
end
