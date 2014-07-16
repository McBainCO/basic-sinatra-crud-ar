class UsersTable
  def initialize(database_connection)
    @database_connection = database_connection
  end


  def finds_name(user_id)
    username = @database_connection.sql("SELECT username FROM users WHERE id = #{user_id}")
    username.pop["username"]
  end

  def username_id_hashes(order=nil)
    if order
      @database_connection.sql("SELECT username, id FROM users ORDER BY username #{order}")
    else
      @database_connection.sql("SELECT username, id FROM users")
    end
  end

  def get_users_data(username)
   @database_connection.sql("SELECT * FROM users WHERE username = '#{username}'")
  end

  def delete_user_from_db_and_their_related_fish(user_delete)
    id = @database_connection.sql("SELECT id FROM users WHERE username = '#{user_delete}'")
    users_id = id.pop["id"]
    @database_connection.sql("DELETE FROM fish WHERE user_id = '#{users_id}'")
    @database_connection.sql("DELETE FROM users WHERE username = '#{user_delete}'")
  end


end