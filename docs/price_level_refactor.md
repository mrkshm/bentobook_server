# Price Level Refactoring Plan

## Overview
This document outlines the plan to refactor the price level display to support multiple currency symbols based on user locale and organization preferences.

## Goals
1. Replace hardcoded `$` symbols with dynamic currency icons
2. Display the correct currency based on user's locale
3. Allow organizations to set a preferred currency that overrides locale detection (future feature, non-essential)

## Implementation Details

### 1. Data Model Updates ✅
- [x] Add `preferred_currency_symbol` to `organizations` table
  - [x] Type: string, nullable
  - [x] Default: nil
  - [x] Valid values: ['dollar', 'yen', 'euro', 'ukp', 'rupees']

### 2. Currency Mapping ✅
Created new concern `CurrencySupport` with locale to currency mapping:

```ruby
# app/models/concerns/currency_support.rb
module CurrencySupport
  extend ActiveSupport::Concern
  
  LOCALE_TO_CURRENCY = {
    'US' => 'dollar',
    'JP' => 'yen',
    'UK' => 'ukp',
    'GB' => 'ukp',  # Alternative UK code
    'EU' => 'euro',
    'IN' => 'rupees',
    # Add more country codes as needed
  }.freeze
  
  def self.currency_for_locale(locale)
    country_code = locale.to_s.split('-').last.upcase
    LOCALE_TO_CURRENCY[country_code] || 'dollar' # Default to dollar
  end
end
```

### 3. Currency Helper ✅
Created `CurrencySymbolHelper` using Heroicons for consistent icon rendering:

```ruby
# app/helpers/currency_symbol_helper.rb
module CurrencySymbolHelper
  include Heroicon::Engine.helpers

  CURRENCY_TO_ICON = {
    "dollar" => "currency-dollar",
    "euro" => "currency-euro",
    "yen" => "currency-yen",
    "ukp" => "currency-pound",
    "rupees" => "currency-rupee"
  }.freeze

  def currency_icon(currency = nil, **options)
    currency ||= Current.organization&.preferred_currency_symbol.presence ||
                CurrencySupport.currency_for_locale(I18n.locale)

    icon_name = CURRENCY_TO_ICON[currency] || "currency-dollar"
    heroicon(icon_name, options.reverse_merge(
      variant: :outline,
      class: "inline-block h-4 w-4"
    ))
  end
end
```

Example usage:
```erb
<%# For a price level of 3 %>
<% 3.times { concat(currency_icon) } %>

<%# With custom styling %>
<%= currency_icon('euro', class: 'h-6 w-6 text-green-500') %>

<%# Using organization's preferred currency %>
<%= currency_icon(Current.organization.preferred_currency_symbol) %>
```

### 4. View Updates
Update `app/views/restaurants/price_levels/_display.html.erb`:

```erb
<%# Replace hardcoded $ with dynamic icon %>
<%= price_level_icon(price_level) %>
```

### 5. Organization Settings (Future Phase)

In a future update, we can add UI to organization settings to select preferred currency. This will be implemented when we're ready to allow users to override the auto-detected currency.

```erb
<%= form_for @organization do |f| %>
  <div class="field">
    <%= f.label :preferred_currency_symbol, 'Preferred Currency' %>
    <%= f.select :preferred_currency_symbol, 
                 options_for_select(
                   [
                     ['Auto-detect (based on locale)', ''],
                     ['Dollar ($)', 'dollar'],
                     ['Yen (¥)', 'yen'],
                     ['Euro (€)', 'euro'],
                     ['British Pound (£)', 'ukp'],
                     ['Rupees (₹)', 'rupees']
                   ], 
                   @organization.preferred_currency_symbol
                 ),
                 {}, 
                 class: 'form-control' %>
  </div>
  <%= f.submit 'Save Changes', class: 'btn btn-primary' %>
<% end %>
```

### 6. Caching Strategy
- Cache the resolved currency symbol in Redis with organization ID as key
- Invalidate cache when organization settings are updated
- Consider using fragment caching for the price level display

### 7. Testing Plan

#### Model Tests
- Test `CurrencySupport` module methods
- Test organization currency preference validation

#### Helper Tests
- Test `price_level_icon` helper with different scenarios:
  - Organization has preferred currency
  - No preferred currency (fallback to locale)
  - Invalid locale (fallback to default)

#### Request/Feature Tests
- Test price level display with different user locales
- Test organization preference override
- Test caching behavior

### 8. Implementation Steps

1. **Database Migration** ✅
   - [x] Add `preferred_currency_symbol` to organizations

2. **Backend Implementation** ✅
   - [x] Create `CurrencySupport` concern
   - [x] Create `CurrencySymbolHelper` with Heroicons integration
   - [ ] (Future) Update organization controller to handle new preference

3. **Frontend Implementation**
   - [ ] Update price level partial to use new `currency_icon` helper
   - [ ] (Future) Add currency selection to organization settings

4. **Testing**
   - Add unit tests
   - Add integration tests
   - Manual testing with different locales

5. **Deployment**
   - Run migrations
   - Deploy code changes
   - Verify in staging environment
   - Deploy to production

## Future Considerations
- Add more currency symbols as needed
- Consider supporting custom currency symbols
- Add currency conversion functionality
- Consider storing price levels with their actual monetary values