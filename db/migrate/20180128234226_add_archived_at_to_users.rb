class AddArchivedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :archived_at, :datetime
  end
end
