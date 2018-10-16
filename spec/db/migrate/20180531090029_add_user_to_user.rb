class AddUserToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user, :string
  end
end
