class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pm, :boolean
    add_column :users, :cm, :boolean
    add_column :users, :admin, :boolean
  end
end
