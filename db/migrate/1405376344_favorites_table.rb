class FavoritesTable < ActiveRecord::Migration
  def up
    create_table :favorites do |t|
      t.integer :fish_id
      t.integer :user_id
    end
  end

  def down
    drop_table :favorites
  end
end

