 class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :password
    end

    create_table :fish do |t|
      t.string :fishname
      t.string :wiki_link
      t.integer :user_id
    end

    add_index :users, :username, unique: true
  end

  def down
    drop_table :users
    drop_table :fish
  end
end
