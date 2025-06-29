# After bundle configurations
########################################
def setup_after_bundle(template_choice)
  puts yellow("🔧 Running final setup...")

  # Database setup
  puts yellow("📊 Setting up database...")
  rails_command "db:drop db:create db:migrate"
  puts green("✅ Database setup completed!")

  # Custom error pages setup
  setup_error_pages  # Template-specific post-bundle setup
  case template_choice
  when :bootstrap
    puts yellow("🅱️  Setting up Bootstrap JavaScript...")
    setup_bootstrap_javascript
  when :tailwind
    puts yellow("🎨 Installing Tailwind CSS...")
    rails_command "tailwindcss:install"
    puts green("✅ Tailwind CSS installed!")

    # Update render-build.sh for Tailwind
    setup_tailwind_render_build

    # Update .overcommit.yml for Tailwind (remove SCSSLint)
    setup_tailwind_overcommit
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

  # Git initialization
  puts yellow("📦 Initializing Git repository...")
  git :init
  git add: "."
  git commit: "-m 'rails new'"
  puts green("✅ Git repository initialized!")

  puts "\n"
  puts green("🎉 #{template_choice.to_s.capitalize} template setup completed successfully!")
  puts blue("📝 Your Rails application is ready to go!")
  puts "\n"
end
