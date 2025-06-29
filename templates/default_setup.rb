# Default Template Setup
########################################

def setup_default_template
  puts yellow("🔧 Setting up Default template...")

  # Add default specific gems
  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "autoprefixer-rails"
      # gem "font-awesome-sass", "~> 6.1"
      gem "sassc-rails"
      gem 'scss_lint', require: false

    RUBY
  end

  # Setup default stylesheets
  run "rm -rf app/assets/stylesheets"
  run "mv tmp/rails_template-main/stylesheets app/assets/stylesheets"
  run "mv tmp/rails_template-main/.scss-lint.yml ."

  puts green("✅ Default template configured!")
end
