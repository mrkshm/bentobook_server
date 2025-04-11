require "rails_helper"

RSpec.describe ShareMailer, type: :mailer do
  describe '#share_notification' do
    let(:creator) { create(:user) }
    let(:source_organization) { create(:organization) }
    let(:target_organization) { create(:organization, email: 'target@example.com') }
    let(:source_membership) { create(:membership, user: creator, organization: source_organization) }
    let(:list) { create(:list, organization: source_organization, creator: creator) }
    let(:share) { create(:share,
                        creator: creator,
                        source_organization: source_organization,
                        target_organization: target_organization,
                        shareable: list) }
    let(:mail) { ShareMailer.share_notification(share) }

    before do
      Rails.application.routes.default_url_options[:host] = 'example.com'
      source_membership # ensure membership is created
    end

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('share_mailer.share_notification.subject',
                                        creator: creator.display_name,
                                        organization: source_organization.name))
      # Send to all admins of the target organization or fall back to org email
      expect(mail.to).to eq([ target_organization.email ])
      expect(mail.from).to eq([ 'noreply@bentobook.app' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(creator.display_name)
      expect(mail.body.encoded).to match(source_organization.name)
      expect(mail.body.encoded).to match(list.name)
    end

    it 'includes the correct sharing information' do
      expect(mail.body.encoded).to match(list.name)
      expect(mail.body.encoded).to match(share.permission.to_s)
      expect(mail.body.encoded).to include(list_url(id: list.id, locale: nil))
    end
  end
end
