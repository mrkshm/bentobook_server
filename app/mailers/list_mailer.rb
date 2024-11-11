class ListMailer < ApplicationMailer
  def export(list, recipient_email)
    @list = list
    @content = ListMarkdownExporter.new(list).generate
    @sender = list.owner
    
    mail(
      to: recipient_email,
      subject: t('.subject', list: list.name),
      reply_to: @sender.email
    )
  end
end
