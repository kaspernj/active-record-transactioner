# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: active-record-transactioner 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "active-record-transactioner"
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kasper Johansen"]
  s.date = "2015-12-05"
  s.description = "Queue up calls to specific models and execute them in transactions, after a certain number of models have been added."
  s.email = "kj@gfish.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "active-record-transactioner.gemspec",
    "config/best_project_practice_rubocop.yml",
    "config/best_project_practice_rubocop_todo.yml",
    "lib/active-record-transactioner.rb",
    "shippable.yml",
    "spec/active-record-transactioner_spec.rb",
    "spec/dummy/README.rdoc",
    "spec/dummy/Rakefile",
    "spec/dummy/app/assets/images/.keep",
    "spec/dummy/app/assets/javascripts/application.js",
    "spec/dummy/app/assets/stylesheets/application.css",
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/controllers/concerns/.keep",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/mailers/.keep",
    "spec/dummy/app/models/concerns/.keep",
    "spec/dummy/app/models/user.rb",
    "spec/dummy/app/views/layouts/application.html.erb",
    "spec/dummy/bin/bundle",
    "spec/dummy/bin/rails",
    "spec/dummy/bin/rake",
    "spec/dummy/config.ru",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/database.example.yml",
    "spec/dummy/config/database.shippable.yml",
    "spec/dummy/config/database.yml",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/filter_parameter_logging.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/secret_token.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/initializers/wrap_parameters.rb",
    "spec/dummy/config/locales/en.yml",
    "spec/dummy/config/routes.rb",
    "spec/dummy/db/migrate/20141203180942_create_users.rb",
    "spec/dummy/db/schema.rb",
    "spec/dummy/lib/assets/.keep",
    "spec/dummy/log/.keep",
    "spec/dummy/public/404.html",
    "spec/dummy/public/422.html",
    "spec/dummy/public/500.html",
    "spec/dummy/public/favicon.ico",
    "spec/models/user_spec.rb",
    "spec/models/user_threadded_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/basic_user_operations.rb",
    "spec/test_classes/active-record-transactioner-test-class.rb"
  ]
  s.homepage = "http://github.com/kaspernj/active-record-transactioner"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Queue up calls to specific models and execute them in transactions, after a certain number of models have been added."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rails>, ["~> 4.0.10"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 3.4.0"])
      s.add_development_dependency(%q<rdoc>, "~> 6.2")
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_development_dependency(%q<builder>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, "= 1.4.2")
      s.add_development_dependency(%q<mysql2>, "= 0.5.3")
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<best_practice_project>, [">= 0"])
      s.add_development_dependency(%q<rubocop>, "= 0.80.1")
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 4.0.10"])
      s.add_dependency(%q<rspec-rails>, ["~> 3.4.0"])
      s.add_dependency(%q<rdoc>, "~> 6.2")
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<sqlite3>, "= 1.4.2")
      s.add_dependency(%q<mysql2>, "= 0.5.3")
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<best_practice_project>, [">= 0"])
      s.add_dependency(%q<rubocop>, "= 0.80.1")
      s.add_dependency(%q<database_cleaner>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 4.0.10"])
    s.add_dependency(%q<rspec-rails>, ["~> 3.4.0"])
    s.add_dependency(%q<rdoc>, "~> 6.2")
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 1.8.4"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<sqlite3>, "= 1.4.2")
    s.add_dependency(%q<mysql2>, "= 0.5.3")
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<best_practice_project>, [">= 0"])
    s.add_dependency(%q<rubocop>, "= 0.80.1")
    s.add_dependency(%q<database_cleaner>, [">= 0"])
  end
end

