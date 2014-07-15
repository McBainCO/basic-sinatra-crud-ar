require "sinatra"
require "active_record"

require "rack-flash"
 require_relative "model"

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

  post "/" do
    username = params[:username]
    password = params[:password]

    login_user_create_session(username, password)
  end

  post "/delete_user" do
    user_to_delete = params[:delete_user]
    delete_user_from_db(user_to_delete)
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

  get "/fish_factory" do
    erb :fish
  end

  post "/fish_factory" do
    fish = params[:fishname]
    wiki = params[:wiki]
    insert_fish(fish, wiki)
    redirect '/'
  end

  get "/logout" do
    session.delete(:user_id)
    redirect '/'
  end

  get "/user/:username" do
    user = params[:username]
    erb :user_page, locals: { :user => user, :fish_data => users_fish_list(user) }
  end


  post "/add_as_favorite/:username" do
   user = params[:username]
   fish_id = params[:fish_id]
   user_id = params[:user_id]

   favoritor_user_id(fish_id, user_id)
   redirect "/user/#{user}"


  end

end
