class AddPreferredCurrencySymbolToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :preferred_currency_symbol, :string
  end
end
