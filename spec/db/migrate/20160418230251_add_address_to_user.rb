class AddAddressToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :address_id, :integer
  end
end
