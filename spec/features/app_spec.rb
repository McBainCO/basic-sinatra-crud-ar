require "spec_helper"
require_relative "method"

feature "Homepage" do
  scenario "unregistered user should see a register button" do
    visit '/'

    expect(page).to have_button("Register")
  end

  scenario "registered user should be able to link to add a fish" do
    visit "/"
    register_user("Frankie")
    expect(page).not_to have_link("Add Fish")
    sign_in_user("Frankie")
    expect(page).to have_link("Add Fish")

  end

  scenario "unregistered user can click button and be directed to a  registration page" do
    visit '/'

    click_link "Register"

    expect(page).to have_content("Register Here!")
  end

  scenario "user can sign in and have a greeting presented to them" do
    register_user("Frankie")

    sign_in_user("Frankie")

    expect(page).to have_content("Welcome Frankie")
  end

  scenario "user should not see register button after logging in" do
    register_user("Frankie")
    sign_in_user("Frankie")

    expect(page).to_not have_button("Register")
    expect(page).to have_content("Logout")
  end

  scenario "logout button ends session" do
    register_user("Frankie")
    sign_in_user("Frankie")
    logout_user

    expect(page).to have_button("Register")
  end

  scenario "can login and see the other users" do
    register_user("Frankie")
    register_user("Maude")

    sign_in_user("Maude")

    expect(page).to have_content("Welcome Maude")
    expect(page).to have_content("Frankie")

  end

  scenario "can view fish others created by clicking on their name" do
    register_user("Frankie")
    register_user("Maude")
    sign_in_user("Frankie")
    create_fish("Mackerel")
    logout_user
    sign_in_user("Maude")

    click_link "Frankie"

    expect(page).to have_content("Mackerel")
  end

  scenario "user can choose a button to order users in asc or desc order" do
    register_user("Bert")
    register_user("Alfred")
    register_user("Drexel")
    register_user("Zorro")
    sign_in_user("Zorro")

    choose("asc")
    click_button("Reorder")

    expect(page.body.index("Alfred")).to be < page.body.index("Bert")
    expect(page.body.index("Bert")).to be < page.body.index("Drexel")

    choose("desc")
    click_button("Reorder")

    expect(page.body.index("Alfred")).to be > page.body.index("Bert")
    expect(page.body.index("Bert")).to be > page.body.index("Drexel")
  end

  scenario "as a loggedin user I can delete other users" do
    register_user("Bert")
    register_user("Alfred")
    sign_in_user("Alfred")

    click_button("Delete Bert")

    expect(page).to_not have_content("Bert")
  end

end

feature "Registering" do
  scenario "user can register and see confirmation" do
    register_user("Frankie")

    expect(page).to have_content("Thank you for registering")
  end
end

feature "Error Messages" do
  scenario "user signs in with blank username or password" do
    visit '/'

    fill_in "username", :with =>""
    fill_in "password", :with =>"123"
    click_button "Sign In"

    expect(page).to have_content "No username provided"

    fill_in "username", :with =>"hello"
    fill_in "password", :with =>""
    click_button "Sign In"

    expect(page).to have_content "No password provided"

    fill_in "username", :with =>""
    fill_in "password", :with =>""
    click_button "Sign In"

    expect(page).to have_content "No username or password provided"
  end

  scenario "user registers with blank username or password" do
    visit '/registration'

    fill_in "username", :with =>""
    fill_in "password", :with =>"123"
    click_button "Submit"

    expect(page).to have_content "No username provided"

    fill_in "username", :with =>"hello"
    fill_in "password", :with =>""
    click_button "Submit"

    expect(page).to have_content "No password provided"

    fill_in "username", :with =>""
    fill_in "password", :with =>""
    click_button "Submit"

    expect(page).to have_content "No username or password provided"
  end

  scenario "user registers with existing username" do
    visit '/registration'

    fill_in "username", :with =>"FrankieRulz"
    fill_in "password", :with =>"123"
    click_button "Submit"

    visit '/registration'

    fill_in "username", :with =>"FrankieRulz"
    fill_in "password", :with =>"123"
    click_button "Submit"

    expect(page).to have_content "This user already exists"
  end
end

feature "fishes" do
  scenario "logged in users can create a fish w/ wiki and view all fish on homepage" do
    register_user("Francis")
    sign_in_user("Francis")

    visit '/fish_factory'

    fill_in "fishname", :with => "Mackerel"
    fill_in "wiki", :with => "http://en.wikipedia.org/wiki/Mackerel"
    click_button "Submit"

    expect(page).to have_content("Mackerel")
  end

  scenario "logged in user can favorite other user fish" do
    register_user("Francis")
    sign_in_user("Francis")
    create_fish("sethfish")
    logout_user


    register_user("seth")
    sign_in_user("seth")

    click_link "Francis"

    expect(page).to have_button("Favorite")

    click_on "Favorite"

    expect(page).to have_content("Favorited")



  end




end


