# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  about      :text
#  email      :string
#  name       :string
#  username   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Organization < ApplicationRecord
  include CurrencySupport

  has_many :memberships
  has_many :users, through: :memberships
  has_many :restaurants
  has_many :images, as: :imageable, dependent: :destroy
  has_many :lists, dependent: :destroy

  # Avatar attachments
  has_one_attached :avatar_medium
  has_one_attached :avatar_thumbnail

  # Virtual attribute for avatar upload
  attr_accessor :avatar

  # Validations
  validates :username, uniqueness: true, allow_blank: true
  validates :about, length: { maximum: 500 }, allow_blank: true
  validates :preferred_currency_symbol, presence: true, allow_blank: true, format: { with: /\A(?:dollar|yen|euro|ukp|rupees)\z/ }, allow_nil: true

  # Shares where this organization is the source (owner sharing with others)
  has_many :outgoing_shares, class_name: "Share", foreign_key: "source_organization_id", dependent: :destroy

  # Shares where this organization is the target (receiving shared items)
  has_many :incoming_shares, class_name: "Share", foreign_key: "target_organization_id", dependent: :destroy

  # Lists shared with this organization
  has_many :shared_lists, through: :incoming_shares, source: :shareable, source_type: "List"

  has_many :contacts, dependent: :destroy
  has_many :visits, dependent: :destroy

  after_initialize :ensure_currency_symbol_set, if: :new_record?

  # Display methods
  def display_name
    username.presence || name.presence || "Organization #{id}"
  end

  # Avatar URL helpers
  def avatar_medium_url
    generate_url(avatar_medium)
  end

  def avatar_thumbnail_url
    generate_url(avatar_thumbnail)
  end

  def share_list(list, target_organization, options = {})
    raise ArgumentError, "List doesn't belong to this organization" unless lists.include?(list)

    outgoing_shares.create!({
      shareable: list,
      target_organization: target_organization,
      creator: options[:creator],
      permission: options[:permission] || :view,
      reshareable: options[:reshareable] || false,
      status: :pending
    })
  end

  def shared_lists_with(organization)
    List.joins(:shares)
        .where(shares: {
          source_organization_id: self.id,
          target_organization_id: organization.id,
          status: :accepted
        })
  end

  def pending_shared_lists_with(organization)
    List.joins(:shares)
        .where(shares: {
          source_organization_id: self.id,
          target_organization_id: organization.id,
          status: :pending
        })
  end

  def accept_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless share.target_organization_id == self.id
    share.update!(status: :accepted)
  end

  def reject_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless share.target_organization_id == self.id
    share.update!(status: :rejected)
  end

  private

  def generate_url(attachment)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  rescue StandardError => e
    Rails.logger.error "Error generating avatar URL: #{e.message}"
    nil
  end

  def ensure_currency_symbol_set
    return unless preferred_currency_symbol.blank?

    if defined?(Current.request) && Current.request&.env["HTTP_ACCEPT_LANGUAGE"].present?
      browser_locale = Current.request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}\-[A-Z]{2}/).first
      detect_and_set_currency(browser_locale) if browser_locale.present?
    else
      detect_and_set_currency(I18n.locale)
    end
  end
end
