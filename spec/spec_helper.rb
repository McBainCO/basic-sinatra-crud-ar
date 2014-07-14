require_relative "./../app"
require "capybara/rspec"
ENV["RACK_ENV"] = "test"

Capybara.app = App

database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])

RSpec.configure do |config|
  config.before do
    database_connection.sql("BEGIN")
  end

  config.after do
    database_connection.sql("ROLLBACK")
  end
end

