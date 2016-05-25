class AddLastLoggedInToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_logged_in, :datetime
  end
end
