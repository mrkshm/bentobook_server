module Visits
  class ContactsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_visit

    def show
      render(Visits::ContactsComponent.new(visit: @visit))
    end

    def edit
      render(Visits::Contacts::SelectorComponent.new(visit: @visit))
    end

    def create
      contact = current_user.contacts.find(params[:contact_id])
      @visit.contacts << contact unless @visit.contacts.include?(contact)

      # Both native and web should use turbo_stream to update in place
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@visit, :contacts),
            Visits::Contacts::SelectorComponent.new(visit: @visit).render_in(view_context)
          )
        end

        # Fallback for non-Turbo clients
        format.html { redirect_to visit_path(id: @visit.id, locale: current_locale) }
      end
    end

    def destroy
      contact = @visit.contacts.find(params[:contact_id])
      @visit.contacts.delete(contact)

      # Both native and web should use turbo_stream to update in place
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@visit, :contacts),
            Visits::Contacts::SelectorComponent.new(visit: @visit).render_in(view_context)
          )
        end

        # Fallback for non-Turbo clients
        format.html { redirect_to visit_path(id: @visit.id, locale: current_locale) }
      end
    end

    def search
      @contacts = current_user.contacts
                            .where.not(id: @visit.contact_ids)
                            .search(params[:query])
                            .order(:name)
                            .limit(10)

      render turbo_stream: turbo_stream.update(
        "search-results",
        partial: "visits/contacts/list",
        locals: { contacts: @contacts }
      )
    end

    private

    def set_visit
      @visit = current_user.visits.find(params[:visit_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to visits_path, alert: t("errors.visits.not_found")
    end
  end
end
