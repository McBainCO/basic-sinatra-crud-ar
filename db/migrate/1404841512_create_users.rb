 class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :password
    end

    add_index :users, :username, unique: true
  end

  def down
    drop_table :users

  end
end
