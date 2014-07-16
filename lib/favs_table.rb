class FavsTable
  def initialize(database_connection)
    @database_connection = database_connection
  end

  def favoritor_user_id(fish_id, user_id)
    @database_connection.sql("INSERT INTO favorites (fish_id, user_id) VALUES (#{fish_id.to_i}, #{user_id.to_i})")
  end



end