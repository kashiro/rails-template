# TODO

## foreman
* for production (Procfile.prod)

## web server
* nginx (include reverse proxy for production)

## Dockert
* dockert
* fig

# USAGE

## use template

```
rails new ${app_name} -m ${URL}
```

## server

development / test

```bash
foreman start -f Procfile.dev
```

# Reference

* http://www.rubydoc.info/github/wycats/thor/Thor/Actions#gsub_file-instance_method
* https://github.com/RailsApps/rails-composer/blob/master/composer.rb
* http://guides.rubyonrails.org/rails_application_templates.html
