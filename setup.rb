# def ask_yes_or_no(question)
#   valid_answers = { "yes" => true, "y" => true, "no" => false }
#
#   answer = nil
#   until valid_answers.key?(answer)
#     answer = ask("\n#{question} (yes/no)").strip.downcase
#   end
#
#   valid_answers[answer]
# end
#
# apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/minimal.rb"
#
# if ask_yes_or_no("Install Bootstrap?")
#   apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/bootstrap.rb"
# end
#
# if ask_yes_or_no("Install Devise?")
#   apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/devise.rb"
# end

say "\n🎉 Start Minimal setup...", :blue

run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do\n" do
  <<~RUBY
    gem "ostruct", "~> 0.1.0"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
    gem "sassc-rails"

  RUBY
end

inject_into_file "Gemfile", after: "group :development, :test do\n" do
  <<~RUBY
    gem "dotenv-rails"
    gem "brakeman", require: false
    gem "bundler-audit", require: false
    gem "overcommit"
    gem "rubocop", require: false
    gem "rubocop-discourse", require: false
    gem "rubocop-rails", require: false

  RUBY
end



inject_into_file "Gemfile", after: "group :development do\n" do
  <<~RUBY
    gem "hotwire-livereload"

  RUBY
end

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"

# Setup
########################################
run "mkdir -p .github"
run "curl -L https://github.com/jotaEmeCortat/rails_template/archive/main.zip > rails_template.zip"
run "unzip -q -o rails_template.zip -d tmp && rm -f rails_template.zip"
run "mv tmp/rails_template-main/stylesheets app/assets/stylesheets"
run "mv tmp/rails_template-main/workflows ./.github/"
run "mv tmp/rails_template-main/dependabot.yml ./.github/"
run "mv tmp/rails_template-main/.rubocop.yml ."
run "mv tmp/rails_template-main/.overcommit.yml ."
run "mv tmp/rails_template-main/render.yaml ."
run "mv tmp/rails_template-main/commitizen ./bin/"
run "mv tmp/rails_template-main/render-build.sh ./bin/"
run "rm -rf tmp/rails_template-main"

# Layout
########################################
gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

run "mkdir -p app/views/components"

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

# General Config
########################################
general_config = <<~RUBY
  config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
RUBY

environment general_config

# After bundle
########################################
after_bundle do
  # Generators: db
  rails_command "db:drop db:create db:migrate"

  # Generators: simple_form
  generate("simple_form:install")

  # Custom error pages
  run "rm -f public/*.html"

  environment <<~RUBY, env: 'production'
    config.exceptions_app = self.routes
  RUBY

  generate(:controller, "errors", "--skip-routes")

  gsub_file "config/routes.rb", /end\s*\z/ do
    <<~RUBY

      # Custom error pages
      match "/:code", to: "errors#error_page", via: :all,
        constraints: { code: /(400|404|406|422|500)/ }

      # Test routes for error simulation (development only)
      if Rails.env.development?
        get "/force_404", to: "errors#error_page", defaults: { code: "404" }
      end
    end
    RUBY
  end

  inject_into_class "app/controllers/errors_controller.rb", "ErrorsController" do
    <<~RUBY

      VALID_STATUS_CODES = %w[400 404 406 422 500]

      def error_page
        status_code = VALID_STATUS_CODES.include?(params[:code]) ? params[:code] : "500"
        respond_to do |format|
          format.html { render "error_page", status: status_code }
          format.any  { head status_code }
        end
      end
    RUBY
  end

  file "app/views/errors/error_page.html.erb", <<~ERB
    <h1><%= response.code %></h1>
  ERB

  # Gitignore
  append_file ".gitignore", <<~TXT

    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Dotenv
  run "touch '.env'"

  # Setup
  run "overcommit --install"
  run "overcommit --sign pre-commit"
  run "overcommit --sign pre-push"
  say "\n🎉 Overcommit installed successfully!", :yellow

  run "chmod +x ./bin/commitizen"
  say "\n🎉 Commitizen installed successfully!", :yellow


  # Deploy config
  run "chmod a+x bin/render-build.sh"
  say "\n🎉 Deploy config successfully!", :yellow

  run "rm -f template.rb"

  # Rubocop fix
  ########################################
  Bundler.with_unbundled_env do
    run "bundle exec rubocop -a || true"
  end
  say "\n🎉 Rubocop auto-corrected your code!", :yellow
  say "\n🎉 Minimal setup completed successfully!", :blue

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'rails new' --no-verify"
end
