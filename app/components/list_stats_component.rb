class ListStatsComponent < ViewComponent::Base
  def initialize(statistics:, list:)
    @statistics = statistics
    @list = list
  end

  private

  attr_reader :statistics, :list
end
