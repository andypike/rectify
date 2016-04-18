class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false, :default => ""
      t.string :number, :null => false, :default => ""

      t.timestamps :null => false
    end

    add_index :contacts, :user_id
  end
end
