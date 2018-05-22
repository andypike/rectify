class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.string :street,    :null => false, :default => ""
      t.string :town,      :null => false, :default => ""
      t.string :city,      :null => false, :default => ""
      t.string :post_code, :null => false, :default => ""

      t.timestamps :null => false
    end
  end
end
