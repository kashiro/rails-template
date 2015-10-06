
raw_repository = "https://raw.githubusercontent.com/kashiro/rails-template/master"

# >---------------------------- question -----------------------------<
use_capybara = yes?("use capybara ?")
use_capybara_webkit = yes?("use capybara-webkit ?")
use_app_server_name = ask("whant kind of app server do you use ?\n    - WEBrik\n    - unicorn\n\n    select : ")
use_db_name_in_dev = ask("whant kind of DB do you use in development and test ?\n    - sqlite\n    - mysql\n\n    select : ")
use_db_name_in_prod = ask("whant kind of DB do you use in production ?\n    - PostgreSQL\n    - mysql\n\n    select : ")
@use_same_db = use_db_name_in_dev == use_db_name_in_prod
add_git = yes?("use git init ?")
has_qmake = run "which qmake"

# >---------------------------- alert -----------------------------<
if use_capybara_webkit && !has_qmake then
  puts "---------------------------------------"
  puts "You have to install Qt library. ( e.g. mac : brew install qt )"
  puts "if you want to know detail check below."
  puts "https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit"
  puts "---------------------------------------"
  exit
end

# >---------------------------- add config -----------------------------<
get "#{raw_repository}/.editorconfig", ".editorconfig"
get "#{raw_repository}/Procfile.dev", "Procfile.dev"

# >---------------------------- Gemfile -----------------------------<

def use_db(selected, name)
  if selected == name && !@use_same_db then
    gem selected
  end
end

uncomment_lines "Gemfile", /gem 'unicorn'/
comment_lines "Gemfile", /gem 'coffee-rails'/
comment_lines "Gemfile", /gem 'sqlite/
gem "foreman"

if @use_same_db then
  gem use_db_name_in_dev
end

gem_group :production do
  use_db use_db_name_in_prod, "PostgreSQL"
  use_db use_db_name_in_prod, "mysql"
end

gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara" if use_capybara

  if use_capybara_webkit then
	  gem "capybara-webkit"
	  gem "database_cleaner"
  end

  use_db use_db_name_in_dev, "sqlite"
  use_db use_db_name_in_dev, "mysql"
end

gem_group :production do
  if use_db_name_in_prod == "PostgreSQL" then
    gem "pg"
  elsif use_db_name_in_prod == "mysql" then
	  gem "mysql"
  end
end

gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara" if use_capybara

  if use_capybara_webkit then
	  gem "capybara-webkit"
	  gem "database_cleaner"
  end

  if use_db_name_in_dev == "sqlite" then
    gem "sqlite3"
  elsif use_db_name_in_dev == "mysql" then
	  gem "mysql"
  end
end

# >---------------------------- install -----------------------------<
run "bundle install --without production"

# >---------------------------- test framework -----------------------------<
remove_dir "test"
generate "rspec:install"
uncomment_lines "spec/rails_helper.rb", /Dir\[Rails\.root\.join/
run "mkdir spec/support"

## for capybara-webkit
if use_capybara_webkit then
  get "#{raw_repository}/spec/support/database_cleaner.rb", "spec/support/database_cleaner.rb"
  get "#{raw_repository}/spec/support/wait_for_ajax.rb", "spec/support/wait_for_ajax.rb"
  # enable config.use_transactional_fixtures for capybara-webkit
  gsub_file "spec/rails_helper.rb", /config.use_transactional_fixtures = false/, "config.use_transactional_fixtures = true"
  insert_into_file "spec/rails_helper.rb", "Capybara.javascript_driver = :webkit", :after => "require 'rspec/rails'"
end

## for factory-girl
get "#{raw_repository}/spec/factories.rb", "spec/factories.rb"

# >---------------------------- app server -----------------------------<
if use_app_server_name == "unicorn" then
  ## unicorn
  get "#{raw_repository}/config/unicorn.rb", "config/unicorn.rb"
  uncomment_lines "Procfile.dev", /web: bundle exec unicorn/
else
  ## WEBrik
  uncomment_lines "Procfile.dev", /web: bundle exec rails server/
end

# >---------------------------- db -----------------------------<
rake("db:migrate")

# >---------------------------- git -----------------------------<
if add_git then
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end

