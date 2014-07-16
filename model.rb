## REGISTRATION AND SIGNIN LOGIC





def user_registration(username, password)
  if username == "" || password == ""
    username_and_password(username, password)
    redirect '/registration'
  else
    begin
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')")
      flash[:notice] = "Thank you for registering"
      redirect '/'
    rescue
      flash[:error] = "This user already exists"
      redirect '/'
    end
  end
end

## HOMEPAGE WHEN LOGGED IN

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

def insert_fish(fishname, wiki)
  @database_connection.sql("INSERT INTO fish (fishname, wiki_link, user_id) VALUES ('#{fishname}', '#{wiki}', '#{session[:user_id]}')")
end

def user_fish_data(id)
  @database_connection.sql("SELECT fishname, wiki_link, user_id FROM fish WHERE user_id = '#{id}';")
end



def delete_user_from_db(user_delete)
  id = @database_connection.sql("SELECT id FROM users WHERE username = '#{user_delete}'")
  users_id = id.pop["id"]
  @database_connection.sql("DELETE FROM fish WHERE user_id = '#{users_id}'")
  @database_connection.sql("DELETE FROM users WHERE username = '#{user_delete}'")
end

## USERS FISH PAGE

def users_fish_list(name)
  user = @database_connection.sql("SELECT id FROM users WHERE username = '#{name}';")
  fish_data = @database_connection.sql("SELECT id, fishname, wiki_link, user_id FROM fish;")
  user_hash = user.pop

  fish_data.select do |fish_hash|
    user_hash["id"] == fish_hash["user_id"]
  end
end

def favoritor_user_id(fish_id, user_id)
      @database_connection.sql("INSERT INTO favorites (fish_id, user_id) VALUES (#{fish_id.to_i}, #{user_id.to_i})")

end