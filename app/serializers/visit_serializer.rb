class VisitSerializer
    include Alba::Resource
  
    attributes :id, :date, :title, :notes, :rating, :created_at, :updated_at
  
    attribute :price_paid do |visit|
      if visit.price_paid_cents.present? && visit.price_paid_currency
        {
          amount: sprintf('%.2f', visit.price_paid_cents / 100.0),
          currency: visit.price_paid_currency
        }
      else
        nil
      end
    end
  
    attribute :restaurant do |visit|
      RestaurantSerializer.new(visit.restaurant).to_h if visit.restaurant
    end
  
    attribute :contacts do |visit|
      visit.contacts.map { |contact| ContactSerializer.new(contact).to_h }
    end
  
    attribute :images do |visit|
      visit.images.map do |image|
        {
          id: image.id,
          url: Rails.application.routes.url_helpers.url_for(image.file)
        }
      end
    end
  end
