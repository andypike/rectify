class AddAddressToUser < ActiveRecord::Migration
  def change
    add_column :users, :address_id, :integer
  end
end
