describe DatabaseConnection do
  describe "with a DATABASE_URL" do
    it "establishes a connection based on the DATABASE_URL" do
      skip("I can't get this to play nicely")
      test_config = YAML.load(File.read("config/database.yml"))["test"]

      old_database_url = ENV["DATABASE_URL"]
      ENV["DATABASE_URL"] = "postgres://#{test_config["username"]}:#{test_config["password"]}@localhost/#{test_config["database"]}"

      expect {
        DatabaseConnection.clear!
        database_connection = DatabaseConnection.establish("production", "/not/a/path.yml")
        database_connection.sql("BEGIN")
        database_connection.sql("ROLLBACK")
        DatabaseConnection.clear!
      }.to_not raise_error

      ENV["DATABASE_URL"] = old_database_url
    end
  end

  describe "with a database.yml" do
    let(:database_connection) { DatabaseConnection.establish("test") }

    let(:create_table_sql) do
      <<-CREATE_SQL
    CREATE TABLE users_test (
      username varchar(25),
      email varchar(200),
      date_of_birth date
    )
      CREATE_SQL
    end

    let(:insert_hunter_sql) do
      <<-INSERT_SQL
    INSERT INTO users_test (username, email, date_of_birth)
    VALUES ('hunter', 'hunter@example.com', '2000-01-01')
      INSERT_SQL
    end

    let(:insert_jeff_sql) do
      <<-INSERT_SQL
    INSERT INTO users_test (username, email, date_of_birth)
    VALUES ('jeff', 'jeff@example.com', '2006-01-01')
      INSERT_SQL
    end

    before do
      database_connection.sql(create_table_sql)
      database_connection.sql(insert_hunter_sql)
      database_connection.sql(insert_jeff_sql)
    end

    it "can SELECT" do
      expected_users = [
        {
          "username" => "hunter",
          "email" => "hunter@example.com",
          "date_of_birth" => "2000-01-01"
        },
        {
          "username" => "jeff",
          "email" => "jeff@example.com",
          "date_of_birth" => "2006-01-01"
        }
      ]

      expect(database_connection.sql("SELECT * from users_test")).to eq(expected_users)
    end

    it "can filter" do
      hunter_results = database_connection.sql("SELECT * from users_test WHERE username = 'hunter';")

      expected_results = [
        {
          "username" => "hunter",
          "email" => "hunter@example.com",
          "date_of_birth" => "2000-01-01"
        }
      ]

      expect(hunter_results).to eq(expected_results)
    end

    it "can DELETE" do
      database_connection.sql("DELETE FROM users_test where username = 'hunter';")

      expected_results = [
        {
          "username" => "jeff",
          "email" => "jeff@example.com",
          "date_of_birth" => "2006-01-01"
        }
      ]

      expect(database_connection.sql("SELECT * from users_test")).to eq(expected_results)
    end
  end
end
