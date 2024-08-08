class AddFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :sku, :string
    add_column :products, :serial, :string
    add_column :products, :price, :decimal
    add_column :products, :stock, :integer
  end
end
