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
  run "mv tmp/rails_template-main/.github ."
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
      gem "mini_racer", platforms: :ruby

    RUBY
  end

  # Setup default stylesheets
  run "rm    app/assets/stylesheets/application.css"
  run "cp -r tmp/rails_template-main/stylesheets_default/* app/assets/stylesheets/"

  puts green("✅ Default template configured!")
end

# Bootstrap template setup
def setup_bootstrap_stylesheets
  puts yellow("📁 Creating Bootstrap stylesheet structure...")

  # Create directory structure
  run "mkdir -p app/assets/stylesheets/config"
  run "mkdir -p app/assets/stylesheets/components"
  run "mkdir -p app/assets/stylesheets/pages"

  # Create main application.scss
  create_file "app/assets/stylesheets/application.scss", <<~SCSS
    // Graphical variables
    @import "config/fonts";
    @import "config/colors";
    @import "config/bootstrap_variables";

    // External libraries
    @import "bootstrap";

    // Your CSS partials
    @import "components/index";
    @import "pages/index";
  SCSS

  # Create config files
  create_file "app/assets/stylesheets/config/_fonts.scss", <<~SCSS
    // Import Google fonts
    @import url('https://fonts.googleapis.com/css?family=Nunito:400,700|Work+Sans:400,700&display=swap');

    // Define fonts for body and headers
    $body-font: "Work Sans", "Helvetica", "sans-serif";
    $headers-font: "Nunito", "Helvetica", "sans-serif";

    // To use a font file (.woff) uncomment following lines
    // @font-face {
    //   font-family: "Font Name";
    //   src: font-url('FontFile.eot');
    //   src: font-url('FontFile.eot?#iefix') format('embedded-opentype'),
    //        font-url('FontFile.woff') format('woff'),
    //        font-url('FontFile.ttf') format('truetype')
    // }
    // $my-font: "Font Name";
  SCSS

  create_file "app/assets/stylesheets/config/_colors.scss", <<~SCSS
    // Define variables for your color scheme

    // For example:
    $red: #FD1015;
    $blue: #0D6EFD;
    $yellow: #FFC65A;
    $orange: #E67E22;
    $green: #1EDD88;
    $gray: #0E0000;
    $light-gray: #F4F4F4;
  SCSS

  create_file "app/assets/stylesheets/config/_bootstrap_variables.scss", <<~SCSS
    // This is where you override default Bootstrap variables
    // 1. Find all Bootstrap variables that you can override at the end of each component's documentation under the `Sass variables` anchor
    // e.g. here are the ones you can override for the navbar https://getbootstrap.com/docs/5.3/components/navbar/#sass-variables
    // 2. These variables are defined with default value (see https://robots.thoughtbot.com/sass-default)
    // 3. You can override them below!

    // General style
    $font-family-sans-serif: $body-font;
    $headings-font-family:   $headers-font;
    $body-bg:                $light-gray;
    $font-size-base:         1rem;

    // Colors
    $body-color: $gray;
    $primary:    $blue;
    $success:    $green;
    $info:       $yellow;
    $danger:     $red;
    $warning:    $orange;

    // Buttons & inputs' radius
    $border-radius-sm:            .0625rem;
    $border-radius:               .125rem;
    $border-radius-lg:            .25rem;
    $border-radius-xl:            .5rem;
    $border-radius-xxl:           1rem;

    // Override other variables below!
  SCSS

  # Create components files
  create_file "app/assets/stylesheets/components/_index.scss", <<~SCSS
    // Import your components CSS files here.
    @import "form_legend_clear";
  SCSS


  create_file "app/assets/stylesheets/components/_form_legend_clear.scss", <<~SCSS
    // In bootstrap 5 legend floats left and requires the following element
    // to be cleared. In a radio button or checkbox group the element after
    // the legend will be the automatically generated hidden input; the fix
    // in https://github.com/twbs/bootstrap/pull/30345 applies to the hidden
    // input and has no visual effect. Here we try to fix matters by
    // applying the clear to the div wrapping the first following radio button
    // or checkbox.
    legend ~ div.form-check:first-of-type {
      clear: left;
    }
  SCSS

  # Create pages files
  create_file "app/assets/stylesheets/pages/_index.scss", <<~SCSS
    // Import page-specific CSS files here.
  SCSS

  puts green("✅ Bootstrap stylesheet structure created!")
end

def setup_bootstrap_javascript
  puts yellow("🔧 Setting up Bootstrap JavaScript...")

  # Add Bootstrap JS via importmap
  run "importmap pin bootstrap"
  run "importmap pin @popperjs/core"

  # Import Bootstrap JS in application.js
  inject_into_file "app/javascript/application.js", after: "import \"@hotwired/turbo-rails\"\n" do
    <<~JS
      import '@popperjs/core'
      import 'bootstrap'
    JS
  end

  # Add to manifest.js for Sprockets compatibility
  inject_into_file "app/assets/config/manifest.js", after: "//= link_tree ../images\n" do
    <<~MANIFEST
      //= link popper.js
      //= link bootstrap.min.js
    MANIFEST
  end

  # Ajusta cada pin separadamente, sem concatenar linhas
  gsub_file 'config/importmap.rb', /^pin "bootstrap".*$/, 'pin "bootstrap", to: "bootstrap.min.js", preload: true'
  gsub_file 'config/importmap.rb', /^pin "@popperjs\/core".*$/, 'pin "@popperjs/core", to: "popper.js", preload: true'

  unless File.read('config/importmap.rb').include?('pin "bootstrap"')
    append_file 'config/importmap.rb', "pin \"bootstrap\", to: \"bootstrap.min.js\", preload: true\n"
  end
  unless File.read('config/importmap.rb').include?('pin "@popperjs/core"')
    append_file 'config/importmap.rb', "pin \"@popperjs/core\", to: \"popper.js\", preload: true\n"
  end

  puts green("✅ Bootstrap JavaScript configured!")
end

def setup_bootstrap_template
  puts yellow("🔧 Setting up Bootstrap template...")

  # Add Bootstrap and Font Awesome specific gems
  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "bootstrap", "~> 5.3.3"
      gem "sassc-rails"
      gem "autoprefixer-rails"
      gem "mini_racer", platforms: :ruby
      gem "font-awesome-sass", "~> 6.1"

    RUBY
  end

  # Enable SCSS - Remove default CSS and create SCSS file
  run "rm -f app/assets/stylesheets/application.css"

  # Create Bootstrap stylesheet structure
  setup_bootstrap_stylesheets

  # Import Font Awesome in application.scss
  inject_into_file "app/assets/stylesheets/application.scss", before: "@import \"bootstrap\";\n" do
    "@import 'font-awesome';\n"
  end

  puts green("✅ Bootstrap template configured!")
end

# Tailwind template setup
def setup_tailwind_template
  puts yellow("🔧 Setting up Tailwind template...")

  # Add Tailwind specific gems
  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "tailwindcss-rails", "~> 4.0"

    RUBY
  end

  # Tailwind will be configured via the gem's installer in after_bundle
  # The tailwindcss-rails gem provides a generator to install Tailwind

  puts green("✅ Tailwind template configured!")

  puts yellow("🔧 Updating render-build.sh for Tailwind...")

  # Update render-build.sh to include Tailwind build step
  gsub_file "bin/render-build.sh",
    /# Run database migrations first\nbin\/rails db:migrate/,
    <<~BASH.chomp
      # Run database migrations first
      bin/rails db:migrate

      # Build Tailwind CSS for production
      bin/rails tailwindcss:build
    BASH

  puts green("✅ render-build.sh updated for Tailwind!")
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
    puts yellow("🎨 Installing Bootstrap...")
    setup_bootstrap_javascript
    puts green("✅ Bootstrap installed!")
  when :tailwind
    puts yellow("🎨 Installing Tailwind CSS...")
    rails_command "tailwindcss:install"
    puts green("✅ Tailwind CSS installed!")
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

# Template selection function
def select_template
  puts cyan("Please choose your template type:")
  puts "\n"
  puts "  #{green('1)')} #{yellow('Default')}   - Rails + sass"
  puts "  #{green('2)')} #{yellow('Bootstrap + Font Awesome')} - Rails + Bootstrap 5 + Font Awesome"
  puts "  #{green('3)')} #{yellow('Tailwind')}  - Rails + Tailwind CSS"
  puts "\n"

  template_choice = nil
  until template_choice
    print cyan("Enter your choice (1-3): ")
    input = $stdin.gets.chomp

    case input
    when '1'
      template_choice = :default
      puts green("✨ You selected: Default template")
    when '2'
      template_choice = :bootstrap
      puts green("✨ You selected: Bootstrap template")
    when '3'
      template_choice = :tailwind
      puts green("✨ You selected: Tailwind template")
    else
      puts red("❌ Invalid choice. Please enter 1, 2, or 3.")
    end
  end

  puts "\n"
  puts blue("-" * 50)
  puts blue("🚀 Starting #{template_choice.to_s.capitalize} Template Setup")
  puts blue("-" * 50)
  puts "\n"

  template_choice
end

# Get template choice from user
template_choice = select_template

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
  setup_bootstrap_template
when :tailwind
  setup_tailwind_template
end

puts yellow("📦 Installing gems...")

# Run after bundle setup
after_bundle do
  setup_after_bundle(template_choice)
end
