class AddActiveToProjectsUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :projects_users, :active, :boolean
  end
end
