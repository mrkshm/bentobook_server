class ListMailer < ApplicationMailer
  def export(list, recipient_email, options = {})
    @list = list
    @options = options
    
    mail(
      to: recipient_email,
      subject: t('.subject', list: list.name)
    )
  end
end
