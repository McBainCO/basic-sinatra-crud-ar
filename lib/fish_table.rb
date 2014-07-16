class FishTable
  def initialize(database_connection)
    @database_connection = database_connection
  end

  def user_fish_data(id)
    @database_connection.sql("SELECT fishname, wiki_link, user_id FROM fish WHERE user_id = '#{id}';")
  end



end