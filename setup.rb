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

        # Automated tests
        gem 'guard'
        gem 'guard-minitest'
    RUBY
  end

  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "ostruct", "~> 0.1.0"
      gem "mini_racer", platforms: :ruby

      # assets
      gem "autoprefixer-rails"

      # seed
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

  inject_into_file "app/views/layouts/application.html.erb",
  "   <meta charset=\"utf-8\">\n",
  after: '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'

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
  run "mv tmp/rails_template-main/.github ."
  run "mv tmp/rails_template-main/commitizen ./bin/"
  run "mv tmp/rails_template-main/render-build.sh ./bin/"
  run "mv tmp/rails_template-main/.overcommit.yml ."
  run "mv tmp/rails_template-main/.rubocop.yml ."
  run "mv tmp/rails_template-main/Guardfile ."

  puts green("✅ Configuration files downloaded and configured!")

  puts yellow("⚙️ Setting up environment variables...")

  # Create empty .env file
  run "touch '.env'"

  puts green("✅ Environment files created!")
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


# After bundle configurations
def setup_after_bundle
  puts yellow("🔧 Running final setup...")

  # Database setup
  puts yellow("📊 Setting up database...")
  rails_command "db:create db:migrate"
  puts green("✅ Database setup completed!")

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

  # Git initialization
  puts yellow("📦 Initializing Git repository...")
  git add: "."
  git commit: "-m 'rails new' --no-verify"
  puts green("✅ Git repository initialized!")

  # Clean up temporary files first
  puts yellow("🗑️ Cleaning up template files...")
  run "rm -rf tmp/rails_template-main"
  run "rm -rf tmp/rails_template-main tmp/rails_template.zip"
  puts green("✅ Cleanup completed!")

  puts "\n"
  puts blue("🎉 Your Rails application is ready to go!")
  puts "\n"
end

# Setup common configuration
setup_common_gems
setup_common_files
setup_common_configs
setup_database

# rails run bundle install
puts yellow("📦 Installing gems...")

# Run after bundle setup
after_bundle do
  setup_after_bundle
end
