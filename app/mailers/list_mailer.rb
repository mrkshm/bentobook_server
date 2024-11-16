class ListMailer < ApplicationMailer
  def export(list, recipient_email, options = {})
    @list = list
    @options = options
    @statistics = ListStatistics.new(list: list, user: list.owner)
    
    mail(
      to: recipient_email,
      subject: t('.subject', list: list.name)
    )
  end
end
