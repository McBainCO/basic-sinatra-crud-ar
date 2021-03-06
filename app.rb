require "sinatra"
require "active_record"
require_relative "lib/fish_table"
require_relative "lib/users_table"
require_relative "lib/favs_table"
require "rack-flash"
require "gschool_database_connection"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    dbase_connection_to_pass = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    @users_table = UsersTable.new(dbase_connection_to_pass)
    @fish_table = FishyTable.new(dbase_connection_to_pass)
    @favorites_table = FavsTable.new(dbase_connection_to_pass)
  end

  get "/" do
    asc = params[:asc]
    desc = params[:desc]
    if session[:user_id]
      name = @users_table.finds_name(session[:user_id])
      users_data = @users_table.username_id_hashes(check_for_order(asc, desc))
      fish_data = @fish_table.user_fish_data(session[:user_id])
      erb :homepage2 , locals: {:name => name,
                               :users_data => users_data,
                                :users_fish_data => fish_data }
    else
      erb :homepage
    end
  end

  post "/" do
    username = params[:username]
    password = params[:password]
    login_user_create_session(username, password)
  end

  post "/delete_user" do
    user_to_delete = params[:delete_user]
    @users_table.delete_user_from_db_and_their_related_fish(user_to_delete)
    redirect "/"
  end

  get "/registration" do
    erb :registration
  end

  post "/registration"  do
    username = params[:username]
    password = params[:password]
    user_registration(username, password)
  end

  def user_registration(username, password)
    if username == "" || password == ""
      username_and_password(username, password)
      redirect '/registration'
    else
      begin
        @users_table.create_users(username, password)
        flash[:notice] = "Thank you for registering"
        redirect '/'
      rescue
        flash[:reg_error] = "This user already exists"
        redirect '/registration'
      end
    end
  end

  get "/fish_factory" do
    erb :fish
  end

  post "/fish_factory" do
    fish = params[:fishname]
    wiki = params[:wiki]
    id = session[:user_id]
    @fish_table.insert_fish(fish, wiki, id)
    redirect '/'
  end

  get "/logout" do
    session.delete(:user_id)
    redirect '/'
  end

  get "/user/:username" do
    user = params[:username]
    user_fish_list = users_fish_list(user)
    erb :user_page, locals: { :user => user, :fish_data => user_fish_list}
  end


  def users_fish_list(name)
    user = @users_table.get_user_name(name).pop
    @fish_table.get_fish_data(user)
  end

  post "/add_as_favorite/:username" do
   user = params[:username]
   fish_id = params[:fish_id]
   user_id = params[:user_id]
   @favs_table.favoritor_user_id(fish_id, user_id)
   redirect "/user/#{user}"
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



#CONTROLLER METHODS
###################################################

def login_user_create_session(username, password)
  if username == "" || password == ""
    username_and_password(username, password)
    redirect '/'
  else
    data_name = @users_table.get_users_data(username)
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