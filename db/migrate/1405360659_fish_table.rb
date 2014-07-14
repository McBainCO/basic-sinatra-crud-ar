class FishTable < ActiveRecord::Migration
  def up
    create_table :fish do |t|
      t.string :fishname
      t.string :wiki_link
      t.integer :user_id
    end
  end

  def down
    drop_table :fish
  end
end
