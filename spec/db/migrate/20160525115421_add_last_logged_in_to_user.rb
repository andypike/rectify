class AddLastLoggedInToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_logged_in, :datetime
  end
end
