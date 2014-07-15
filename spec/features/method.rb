
def register_user(name)
  visit '/registration'

  fill_in "Username", :with => "#{name}"
  fill_in "Password", :with => "secretpassword"

  click_button "Submit"



  # expect(page).to have_content("Thank you for registering")
end

def sign_in_user(name)
  visit '/'

  fill_in "Username", :with => "#{name}"
  fill_in "Password", :with => "secretpassword"

  click_button "Sign In"
end

def logout_user
  visit '/logout'
end

def create_fish(fishname)
  visit '/fish_factory'

  fill_in "fishname", :with => "#{fishname}"
  fill_in "wiki", :with => "http://en.wikipedia.org/wiki/Mackerel"

  click_button "Submit"
end

