class AddActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :null => false, :default => true
  end
end
