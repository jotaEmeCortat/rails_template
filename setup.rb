# Load all setup modules
require_relative 'templates/common_setup'
require_relative 'templates/default_setup'
require_relative 'templates/bootstrap_setup'
require_relative 'templates/tailwind_setup'
require_relative 'templates/after_bundle_setup'

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

# Template selection
puts cyan("Please choose your template type:")
puts "\n"
puts "  #{green('1)')} #{yellow('Default')}   - Rails + sass"
puts "  #{green('2)')} #{yellow('Bootstrap')} - Rails + Bootstrap 5"
puts "  #{green('3)')} #{yellow('Tailwind')}  - Rails + Tailwind CSS"
puts "\n"

template_choice = nil
until template_choice
  print cyan("Enter your choice (1-3): ")
  input = gets.chomp

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

# Kill spring processes
run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Execute common setup
setup_common_gems
setup_common_configs
setup_template_files
setup_database
setup_environment

# Execute template-specific setup
case template_choice
when :default
  setup_default_template
when :bootstrap
  setup_bootstrap_template
when :tailwind
  setup_tailwind_template
end

# Clean up
puts yellow("🗑️ Clean up template files...")
run "rm -rf tmp/rails_template-main"

puts "\n"
puts green("🎉 #{template_choice.to_s.capitalize} template setup completed!")
puts "\n"

# After bundle installation - Final setup
after_bundle do
  setup_after_bundle(template_choice)
end
