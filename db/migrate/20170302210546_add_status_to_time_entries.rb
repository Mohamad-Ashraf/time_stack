class AddStatusToTimeEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :time_entries, :status_id, :integer
  end
end
