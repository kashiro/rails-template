
# >---------------------------- question -----------------------------<
use_capybara? = yes?("use capybara")
use_capybara_webkit? = yes?("use capybara-webkit")

# >---------------------------- Gemfile -----------------------------<
gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara" if use_capybara?
  if use_capybara_webkit? then
	gem "capybara-webkit"
	gem "database_cleaner"
  end
end

# >---------------------------- install -----------------------------<
run "bundle install"
# >---------------------------- test framework -----------------------------<
run "rm -rf test"
generate "rspec:install"
uncomment_lines "spec/rails_helper.rb", /Dir\[Rails\.root\.join/
run "mkdir spec/support"

## for capybara-webkit
if use_capybara_webkit? then
  get "", "spec/support/database_cleaner.rb" 
  get "", "spec/support/wait_for_ajax.rb" 
end

## for factory-girl
get "", "spec/factories.rb" 

