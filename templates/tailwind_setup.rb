# Tailwind Template Setup
########################################

def setup_tailwind_template
  puts yellow("🎨 Setting up Tailwind template...")

  # Add Tailwind specific gems
  inject_into_file "Gemfile", before: "group :development, :test do\n" do
    <<~RUBY
      gem "tailwindcss-rails", "~> 2.0"

    RUBY
  end

  # Tailwind will be configured via the gem's installer in after_bundle
  # The tailwindcss-rails gem provides a generator to install Tailwind

  puts green("✅ Tailwind template configured!")
end

def setup_tailwind_render_build
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

def setup_tailwind_overcommit
  puts yellow("🔧 Updating .overcommit.yml for Tailwind...")

  # Remove SCSSLint section from .overcommit.yml since Tailwind doesn't use SCSS
  gsub_file ".overcommit.yml", /  SCSSLint:.*?node_modules\/\*\*\/\*/m, ""

  puts green("✅ .overcommit.yml updated for Tailwind!")
end
