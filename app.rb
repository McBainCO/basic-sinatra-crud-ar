require "sinatra"
require "active_record"
require "fish_table"
require "users_table"

require "rack-flash"

require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super

    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

  end

  get "/" do
    asc = params[:asc]
    desc = params[:desc]

    if session[:user_id]
      erb :homepage2 , locals: {:name => finds_name(session[:user_id]),
                               :users_data => username_id_hashes(check_for_order(asc, desc)),
                                :users_fish_data => user_fish_data(session[:user_id])}
    else
      erb :homepage
     end

  end
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  def finds_name(user_id)
    username = @database_connection.sql("SELECT username FROM users WHERE id = #{user_id}")
    username.pop["username"]
  end

  post "/" do
    username = params[:username]
    password = params[:password]

    login_user_create_session(username, password)
  end
    #^^^^^^^^^^^^^^^^^^^
      def username_id_hashes(order=nil)
         if order
          @database_connection.sql("SELECT username, id FROM users ORDER BY username #{order}")
        else
          @database_connection.sql("SELECT username, id FROM users")
        end
      end

      def user_fish_data(id)
        @database_connection.sql("SELECT fishname, wiki_link, user_id FROM fish WHERE user_id = '#{id}';")
      end
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  def login_user_create_session(username, password)
    if username == "" || password == ""
      username_and_password(username, password)
      redirect '/'
    else
      data_name = @database_connection.sql("SELECT * FROM users WHERE username = '#{username}'")
      data_name.each do |hash|
        if hash["username"] == username && hash["password"] == password
          session[:user_id] = hash["id"].to_i
        else
          flash[:error] = "Username and Password not found"
        end
      end
      redirect '/'
    end
  end

  post "/delete_user" do
    user_to_delete = params[:delete_user]
    delete_user_from_db(user_to_delete)
    redirect "/"
  end

#-------------------------------
  def delete_user_from_db(user_delete)
    id = @database_connection.sql("SELECT id FROM users WHERE username = '#{user_delete}'")
    users_id = id.pop["id"]
    @database_connection.sql("DELETE FROM fish WHERE user_id = '#{users_id}'")
    @database_connection.sql("DELETE FROM users WHERE username = '#{user_delete}'")
  end


  get "/registration" do
    erb :registration
  end

  post "/registration"  do
    username = params[:username]
    password = params[:password]

    user_registration(username, password)
  end
#^^^^^^^^^^^^^^^^^^^^^^^^
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




  get "/fish_factory" do
    erb :fish
  end

  post "/fish_factory" do
    fish = params[:fishname]
    wiki = params[:wiki]
    insert_fish(fish, wiki)
    redirect '/'
  end

#---------------------------
  def insert_fish(fishname, wiki)
    @database_connection.sql("INSERT INTO fish (fishname, wiki_link, user_id) VALUES ('#{fishname}', '#{wiki}', '#{session[:user_id]}')")
  end

  get "/logout" do
    session.delete(:user_id)
    redirect '/'
  end

  get "/user/:username" do
    user = params[:username]
    erb :user_page, locals: { :user => user, :fish_data => users_fish_list(user) }
  end

#---------------------
  def users_fish_list(name)
    user = @database_connection.sql("SELECT id FROM users WHERE username = '#{name}';")
    fish_data = @database_connection.sql("SELECT id, fishname, wiki_link, user_id FROM fish;")
    user_hash = user.pop

    fish_data.select do |fish_hash|
      user_hash["id"] == fish_hash["user_id"]
    end
  end



  post "/add_as_favorite/:username" do
   user = params[:username]
   fish_id = params[:fish_id]
   user_id = params[:user_id]

   favoritor_user_id(fish_id, user_id)
   redirect "/user/#{user}"
  end

#-----------------------
  def favoritor_user_id(fish_id, user_id)
    @database_connection.sql("INSERT INTO favorites (fish_id, user_id) VALUES (#{fish_id.to_i}, #{user_id.to_i})")

  end

  def username_and_password(username, password)
    if username == "" and password == ""
      flash[:error] = "No username or password provided"
    elsif username == ""
      flash[:error] = "No username provided"
    elsif password == ""
      flash[:error] = "No password provided"
    else
    end
  end

  def check_for_order(asc, desc)
    if asc && desc == nil
      asc
    elsif desc && asc == nil
      desc
    else nil
    end
  end

end
