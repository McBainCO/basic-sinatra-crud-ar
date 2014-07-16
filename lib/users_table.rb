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


end