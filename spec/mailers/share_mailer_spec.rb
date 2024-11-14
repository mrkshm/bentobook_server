require "rails_helper"

RSpec.describe ShareMailer, type: :mailer do
  describe '#share_notification' do
    let(:creator) { create(:user) }
    let(:recipient) { create(:user) }
    let(:list) { create(:list, owner: creator) }
    let(:share) { create(:share, creator: creator, recipient: recipient, shareable: list) }
    let(:mail) { ShareMailer.share_notification(share) }

    before do
      Rails.application.routes.default_url_options[:host] = 'example.com'
    end

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('share_mailer.share_notification.subject', creator: creator.profile.display_name))
      expect(mail.to).to eq([recipient.email])
      expect(mail.from).to eq(['noreply@bentobook.app'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(creator.profile.display_name)
      expect(mail.body.encoded).to match(list.name)
    end

    it 'includes the correct sharing information' do
      expect(mail.body.encoded).to match(list.name)
      expect(mail.body.encoded).to match(share.permission.to_s)
      expect(mail.body.encoded).to include(list_url(id: list.id))
    end
  end
end
