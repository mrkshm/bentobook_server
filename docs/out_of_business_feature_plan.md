# Out of Business Feature Implementation Plan

## Objective
To allow marking restaurants as "out of business" and visually represent this status throughout the application, improving data accuracy and user experience.

## `business_status` Values
We will adhere to the Google Places API `business_status` values for consistency and future compatibility:
*   `OPERATIONAL`
*   `CLOSED_PERMANENTLY` (for "out of business")
*   `CLOSED_TEMPORARILY`

## Implementation Steps

### 1. Backend (Rails)

#### 1.1. Restaurant Model & Database
* DONE   **Business Status Implementation:** Implement `business_status` using constants and validation with helper methods for better control and explicit behavior.
    ```ruby
    # app/models/restaurant.rb
    class Restaurant < ApplicationRecord
      # Business status constants
      BUSINESS_STATUS = {
        operational: "OPERATIONAL",
        closed_permanently: "CLOSED_PERMANENTLY",
        closed_temporarily: "CLOSED_TEMPORARILY"
      }
      
      # Validation for business_status
      validates :business_status, inclusion: { in: BUSINESS_STATUS.values }, allow_nil: true
      
      # Set default business status
      after_initialize :set_default_business_status, if: :new_record?
      
      def set_default_business_status
        self.business_status ||= BUSINESS_STATUS[:operational]
      end
      
      # Helper methods for business status
      def operational?
        business_status == BUSINESS_STATUS[:operational]
      end
      
      def closed_permanently?
        business_status == BUSINESS_STATUS[:closed_permanently]
      end
      
      def closed_temporarily?
        business_status == BUSINESS_STATUS[:closed_temporarily]
      end
    end
    ```

* DONE   **Database Index:** Add an index on `business_status` to optimize filtering, as most queries will filter for `OPERATIONAL` restaurants:
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_add_business_status_index_to_restaurants.rb
    class AddBusinessStatusIndexToRestaurants < ActiveRecord::Migration[7.0]
      def change
        add_index :restaurants, :business_status
      end
    end
    ```



#### 1.1.3. Data Migration:
* DONE  Update any existing `NULL` values to `OPERATIONAL`:
    ```ruby
    # db/migrate/YYYYMMDDHHMMSS_backfill_business_status.rb
    class BackfillBusinessStatus < ActiveRecord::Migration[7.0]
      def up
        Restaurant.where(business_status: nil).update_all(business_status: 'OPERATIONAL')
      end
    end
    ```

#### 1.2. Business Status Controller
* DONE **BusinessStatusController:** Handles updating the business status with proper validation and error handling.
    ```ruby
    # app/controllers/restaurants/business_status_controller.rb
    class Restaurants::BusinessStatusController < ApplicationController
      before_action :set_restaurant
      before_action :authenticate_user!
      before_action :validate_business_status, only: :update

      # GET /restaurants/:restaurant_id/business_status/edit
      def edit
        respond_to do |format|
          format.html { render layout: !hotwire_native_app? }
        end
      end

      # PATCH/PUT /restaurants/:restaurant_id/business_status
      def update
        if @restaurant.update(business_status: params[:business_status])
          handle_successful_update
        else
          handle_failed_update
        end
      end

      private

      def set_restaurant
        @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
      end

      def validate_business_status
        return if Restaurant::BUSINESS_STATUS.value?(params[:business_status])
        
        flash[:alert] = "Invalid business status"
        redirect_to edit_restaurant_business_status_path(@restaurant)
      end

      def handle_successful_update
        respond_to do |format|
          format.html do
            redirect_to @restaurant,
                        status: :see_other,
                        notice: "Business status updated successfully"
          end
          format.turbo_stream do
            render turbo_stream: turbo_stream.action(
              "visit",
              restaurant_path(@restaurant),
              "data-turbo-action": "replace"
            )
          end
        end
      end

      def handle_failed_update
        respond_to do |format|
          format.html do
            flash.now[:alert] = @restaurant.errors.full_messages.to_sentence
            render :edit, status: :unprocessable_entity
          end
          format.turbo_stream do
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end
    ```

    **Routes:**
    ```ruby
    # config/routes.rb
    resources :restaurants do
      resource :business_status, only: [:edit, :update], controller: 'restaurants/business_status'
    end
    ```

#### 1.3. Authorization
*   All restaurant look-ups scope through `Current.organization` (e.g., `Current.organization.restaurants.find(...)`), which restricts updates to members of the owning organization. No additional policy layer is required for this feature.

### 2. Frontend (Rails Views & Stimulus)

#### 2.1. Display Status
*   **Restaurant Detail Page:** Modify `app/views/restaurants/show.html.erb` (or relevant partials) to clearly display the `business_status`. For `CLOSED_PERMANENTLY`, a prominent "Out of Business" badge or text is recommended.
    ```erb
    <%# app/views/restaurants/show.html.erb %>
    <% if @restaurant.business_status == 'CLOSED_PERMANENTLY' %>
      <span class="bg-red-100 text-red-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-red-900 dark:text-red-300">Out of Business</span>
    <% end %>
    ```
*   **Restaurant List/Cards:** In `app/views/restaurants/_restaurant_card.html.erb` (or similar list partials), visually de-emphasize closed restaurants (e.g., grey out, strikethrough text, reduced opacity).



#### 2.2. Filtering/Visibility in Lists
*   **Controller Scope:** Modify the `index` action in `app/controllers/restaurants_controller.rb` to filter restaurants based on `business_status`.
    *   **Default:** By default, only show `OPERATIONAL` restaurants.
    *   **Option to Show All:** Add a UI element (a filter dropdown) to allow users to view `CLOSED_PERMANENTLY` or `CLOSED_TEMPORARILY` restaurants. This would involve passing a parameter to the controller.
    ```ruby
    # app/controllers/restaurants_controller.rb
    def index
      @restaurants = Current.organization.restaurants.all
      if params[:show_closed] != 'true'
        @restaurants = @restaurants.where(business_status: 'OPERATIONAL')
      end
      # ... other filters/pagination
    end
    ```

#### 2.3. Business Status Update UI

Following the same pattern as cuisine selection, we'll create a dedicated edit view that works seamlessly across web and native platforms.

##### 2.4.1. Controller
```ruby
# app/controllers/restaurants/business_status_controller.rb
class Restaurants::BusinessStatusController < ApplicationController
  before_action :set_restaurant
  before_action :authenticate_user!

  def edit
    respond_to do |format|
      format.html { render layout: !hotwire_native_app? }
    end
  end

  def update
    if @restaurant.update(business_status: params[:business_status])
      respond_to do |format|
        format.html { redirect_to @restaurant, status: :see_other }
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(
            "visit",
            restaurant_path(@restaurant),
            "data-turbo-action": "replace"
          )
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    @restaurant = Current.organization.restaurants.find(params[:restaurant_id])
  end
end
```

##### 2.4.2. Routes
```ruby
# config/routes.rb
resources :restaurants do
  resource :business_status, only: [:edit, :update], controller: 'restaurants/business_status'
  # ... other routes
end
```

##### 2.4.3. Edit View
```erb
<%# app/views/restaurants/business_status/edit.html.erb %>
<% if hotwire_native_app? %>
  <% render 'shared/header', title: 'Update Business Status' %>
  <div class="min-h-screen bg-surface-50">
    <div class="container mx-auto px-4 py-6">
<% end %>

<%= turbo_frame_tag dom_id(@restaurant, :business_status) do %>
  <div class="space-y-4">
    <h2 class="text-lg font-bold">Update Business Status</h2>
    
    <%= button_to "Mark as Out of Business",
                restaurant_business_status_path(@restaurant),
                method: :patch,
                params: { business_status: 'CLOSED_PERMANENTLY' },
                class: "btn btn-danger w-full" %>

    <%= button_to "Mark as Operational",
                restaurant_business_status_path(@restaurant),
                method: :patch,
                params: { business_status: 'OPERATIONAL' },
                class: "btn btn-success w-full" %>

    <%= link_to "Cancel", 
              @restaurant, 
              class: "btn btn-outline w-full",
              data: { 
                turbo_frame: hotwire_native_app? ? "_top" : "_self",
                turbo_action: "replace" 
              } %>
  </div>
<% end %>

<% if hotwire_native_app? %>
    </div>
  </div>
<% end %>
```

##### 2.4.4. Restaurant Show Page
Add a link to open the business status editor:

```erb
<%# app/views/restaurants/show.html.erb %>
<%= link_to "Danger Zone", 
            edit_restaurant_business_status_path(@restaurant),
            class: "btn btn-danger",
            data: { turbo_frame: dom_id(@restaurant, :business_status) } %>
```



Example snippet:

```erb
<hr class="my-6">

<details class="danger-zone">
  <summary class="text-red-600 cursor-pointer font-semibold">
    Danger Zone
  </summary>

  <div class="mt-4 space-y-2">
    <% if @restaurant.operational? %>
      <%= button_to "Mark as Out of Business",
          restaurant_business_status_path(@restaurant),
          method: :patch,
          params: { business_status: 'CLOSED_PERMANENTLY' },
          class: "btn btn-danger w-full",
          data: { turbo_confirm: "Really mark this restaurant as out of business?" } %>
    <% else %>
      <%= button_to "Mark as Operational",
          restaurant_business_status_path(@restaurant),
          method: :patch,
          params: { business_status: 'OPERATIONAL' },
          class: "btn btn-success w-full",
          data: { turbo_confirm: "Really mark this restaurant as operational?" } %>
    <% end %>

    <%= button_to "Delete Restaurant",
        restaurant_path(@restaurant),
        method: :delete,
        class: "btn btn-danger w-full",
        data: { turbo_confirm: "This cannot be undone. Delete restaurant?" } %>
  </div>
</details>
```

Adjust the wording ("Danger Zone" vs "Advanced Actions") depending on your audience. Use `data-turbo-confirm` for confirmations.


