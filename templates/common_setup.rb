# Common configurations for all templates
########################################

def setup_common_gems
  puts yellow("📦 Setting up common gems...")

  # Remove default gems
  gsub_file "Gemfile", /gem ['"]sqlite3['"].*\n/, ""
  gsub_file "Gemfile", /gem ['"]jbuilder['"].*\n/, ""

  # Add common gems
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

  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "ostruct", "~> 0.1.0"
      gem "simple_form", github: "heartcombo/simple_form"
      gem "faker"

    RUBY
  end

  inject_into_file "Gemfile", after: "group :development do\n" do
    <<~RUBY
      gem "hotwire-livereload"

    RUBY
  end

  puts green("✅ Common gems configured!")
end

def setup_common_configs
  puts yellow("⚙️ Setting up common configurations...")

  # Update viewport meta tag for better responsive design
  gsub_file(
    "app/views/layouts/application.html.erb",
    '<meta name="viewport" content="width=device-width,initial-scale=1">',
    '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
  )

  # Generators configuration
  generators_config = <<~RUBY
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
  RUBY

  environment generators_config

  # General configuration for Rails 7.1+
  general_config = <<~RUBY
    config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
  RUBY

  environment general_config

  puts green("✅ Common configurations applied!")
end

def setup_template_files
  puts yellow("📁 Setting up template files...")

  run "mkdir -p .github"
  run "curl -L https://github.com/jotaEmeCortat/rails_template/archive/main.zip > rails_template.zip"
  run "unzip -q -o rails_template.zip -d tmp && rm -f rails_template.zip"

  run "mv tmp/rails_template-main/workflows ./.github/"
  run "mv tmp/rails_template-main/dependabot.yml ./.github/"
  run "mv tmp/rails_template-main/.rubocop.yml ."
  run "mv tmp/rails_template-main/.overcommit.yml ."
  run "mv tmp/rails_template-main/render.yaml ."
  run "mv tmp/rails_template-main/commitizen ./bin/"
  run "mv tmp/rails_template-main/render-build.sh ./bin/"
  run "mkdir -p app/views/components"
  
  puts green("✅ Template files configured!")
end

def setup_database
  puts yellow("🗄️ Configuring database...")

  # Update production database configuration
  gsub_file "config/database.yml", /production:.*?(?=\n\S|\nproduction|\z)/m, <<~YAML.chomp
  production:
    <<: *default
    url: <%= ENV["DATABASE_URL"] %>
  YAML

  puts green("✅ Database configured!")
end

def setup_environment
  puts yellow("⚙️ Setting up environment variables...")

  # Create empty .env file
  run "touch '.env'"

  puts green("✅ Environment files created!")
end

def setup_error_pages
  puts yellow("🚨 Setting up custom error pages...")

  # Remove default Rails error pages
  run "rm -f public/*.html"

  # Configure production to use custom error controller
  environment <<~RUBY, env: 'production'
    config.exceptions_app = self.routes
  RUBY

  # Generate errors controller
  generate(:controller, "errors", "--skip-routes")

  # Add custom error routes
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

  # Add error handling logic to controller
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

  # Create error page view
  file "app/views/errors/error_page.html.erb", <<~ERB
    <h1><%= response.code %></h1>
  ERB

  puts green("✅ Custom error pages configured!")
end
