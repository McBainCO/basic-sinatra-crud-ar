class FishyTable
  def initialize(database_connection)
    @database_connection = database_connection
  end

  def user_fish_data(id)
    @database_connection.sql("SELECT fishname, wiki_link, user_id FROM fish WHERE user_id = '#{id}';")
  end

  def insert_fish(fishname, wiki, id)
    @database_connection.sql("INSERT INTO fish (fishname, wiki_link, user_id) VALUES ('#{fishname}', '#{wiki}', '#{id}')")
  end

  def get_fish_data(user_hash)
    @database_connection.sql("SELECT id, fishname, wiki_link, user_id FROM fish WHERE user_id= #{user_hash["id"]}")
  end

end