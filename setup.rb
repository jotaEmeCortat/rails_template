# Rails Template - All-in-One Version
# This version includes all code inline for remote URL usage

# Colors for output
def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end
def blue(text); colorize(text, 34); end
def red(text); colorize(text, 31); end
def cyan(text); colorize(text, 36); end
def magenta(text); colorize(text, 35); end

# Template header
puts "\n"
puts blue("=" * 70)
puts blue("Rails Template")
puts blue("=" * 70)
puts "\n"

# Common configurations for all templates
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
        gem "overcommit", require: false
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

  # Kill any running Spring processes (macOS specific)
  run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

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

def setup_common_files
  puts yellow("📁 Setting up common configuration files...")

  # Download configuration files from GitHub repository
  run "curl  -L  https://github.com/jotaEmeCortat/rails_template/archive/main.zip > rails_template.zip"
  run "unzip -q  -o rails_template.zip -d tmp && rm -f rails_template.zip"

  # Move configuration files to correct locations
  run "mv tmp/rails_template-main/common_files/.github ."
  run "mv tmp/rails_template-main/common_files/commitizen ./bin/"
  run "mv tmp/rails_template-main/common_files/render-build.sh ./bin/"
  run "mv tmp/rails_template-main/common_files/.overcommit.yml ."
  run "mv tmp/rails_template-main/common_files/.rubocop.yml ."

  puts green("✅ Configuration files downloaded and configured!")
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

  # Replace default routes with custom routes file
  run "rm config/routes.rb"
  run "cp tmp/rails_template-main/error_page_files/routes.rb config/"

  # Replace generated controller with custom errors controller
  run "rm app/controllers/errors_controller.rb"
  run "cp tmp/rails_template-main/error_page_files/errors_controller.rb app/controllers/"

  # Create error page view from repository
  run "cp tmp/rails_template-main/error_page_files/error_page.html.erb app/views/errors/"

  puts green("✅ Custom error pages configured!")
end

# Default template setup
def setup_default_template
  puts yellow("🔧 Setting up Default template...")

  # Add default specific gems
  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "autoprefixer-rails"
      gem "sassc-rails"

    RUBY
  end

  # Setup default stylesheets
  run "rm    app/assets/stylesheets/application.css"
  run "cp -r tmp/rails_template-main/stylesheets_default/* app/assets/stylesheets/"

  puts green("✅ Default template configured!")
end

# After bundle configurations
def setup_after_bundle(template_choice)
  puts yellow("🔧 Running final setup...")

  # Database setup
  puts yellow("📊 Setting up database...")
  rails_command "db:drop db:create db:migrate"
  puts green("✅ Database setup completed!")

  # Custom error pages setup
  setup_error_pages

  # Template-specific post-bundle setup
  case template_choice
  when :bootstrap
  when :tailwind
  end

  # Simple Form setup
  puts yellow("📋 Setting up Simple Form...")
  case template_choice
  when :bootstrap
    generate("simple_form:install", "--bootstrap")
  else
    generate("simple_form:install")
  end
  puts green("✅ Simple Form configured!")

  # Gitignore setup
  puts yellow("📝 Updating .gitignore...")
  append_file ".gitignore", <<~TXT

    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT
  puts green("✅ .gitignore updated!")

  # Development tools setup
  puts yellow("🔧 Setting up development tools...")

  # Overcommit
  run "overcommit --install"
  run "overcommit --sign pre-commit"
  run "overcommit --sign pre-push"
  puts green("✅ Overcommit configured!")

  # Commitizen
  run "chmod +x ./bin/commitizen"
  puts green("✅ Commitizen configured!")

  # Deploy configuration
  puts yellow("🚀 Setting up deploy configuration...")
  run "chmod a+x bin/render-build.sh"
  puts green("✅ Deploy configuration ready!")

  # Code formatting
  puts yellow("🎨 Running code formatting...")
  Bundler.with_unbundled_env do
    run "bundle exec rubocop -a || true"
  end
  puts green("✅ Code formatted with Rubocop!")

  # Clean up temporary files first
  puts yellow("🗑️ Cleaning up template files...")
  run "rm -rf tmp/rails_template-main"
  puts green("✅ Cleanup completed!")

  # Git initialization
  puts yellow("📦 Initializing Git repository...")
  git add: "."
  git commit: "-m 'rails new' --no-verify"
  puts green("✅ Git repository initialized!")

  puts "\n"
  puts green("🎉 #{template_choice.to_s.capitalize} template setup completed successfully!")
  puts blue("📝 Your Rails application is ready to go!")
  puts "\n"
end

# Template selection
puts blue("🎨 Choose your template:")
puts "1. Default (Rails + Sass)"
puts "2. Bootstrap (Rails + Bootstrap 5)"
puts "3. Tailwind (Rails + Tailwind CSS)"

print cyan("Enter your choice (1-3): ")
choice = $stdin.gets.chomp.to_i

template_choice = case choice
when 1
  :default
when 2
  :bootstrap
when 3
  :tailwind
else
  puts red("❌ Invalid choice! Using Default template.")
  :default
end

puts blue("✅ Selected: #{template_choice.to_s.capitalize} template")
puts ""

# Setup common configuration
setup_common_gems
setup_common_files
setup_common_configs
setup_database
setup_environment


# Setup template-specific configuration
case template_choice
when :default
  setup_default_template
when :bootstrap
  # setup_bootstrap_template
when :tailwind
  # setup_tailwind_template
end

puts yellow("📦 Installing gems...")

# Run after bundle setup
after_bundle do
  setup_after_bundle(template_choice)
end
