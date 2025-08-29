require "active_support/inflector"

guard :minitest, cmd: "bin/rails test", all_on_start: false, all_after_pass: false do
  # Run the whole suite when helpers or support files change
  watch(%r{^test/test_helper\.rb$})   { "test" }
  watch(%r{^test/support/.*\.rb$})    { "test" }

  # Models → run the corresponding model test
  watch(%r{^app/models/(.*?)\.rb$}) do |m|
    "test/models/#{m[1]}_test.rb"
  end

  # Controllers → run controller + integration tests
  watch(%r{^app/controllers/(.*?)_controller\.rb$}) do |m|
    resource_tests(m[1])
  end

  # Views → run controller + integration tests for that resource
  watch(%r{^app/views/([^/]+)/.*\.(erb|haml|slim)$}) do |m|
    [controller_test(m[1])] + integration_tests(m[1])
  end

  # Mailers → run the corresponding mailer test
  watch(%r{^app/mailers/(.*?)\.rb$}) do |m|
    "test/mailers/#{m[1]}_test.rb"
  end

  # Mailer views → run mailer test
  watch(%r{^app/views/(.*)_mailer/.*}) do |m|
    "test/mailers/#{m[1]}_mailer_test.rb"
  end

  # Helpers → run integration tests for that resource
  watch(%r{^app/helpers/(.*?)_helper\.rb$}) do |m|
    integration_tests(m[1])
  end

  # Routes → run all integration tests
  watch("config/routes.rb") { integration_tests }

  # Test files → run themselves
  watch(%r{^test/.+_test\.rb$})
end

##
# HELPER METHODS
##

# Returns integration tests for a given resource, or all
def integration_tests(resource = :all)
  if resource == :all
    Dir["test/integration/**/*_test.rb"]
  else
    Dir["test/integration/#{resource}_*_test.rb"]
  end
end

# Returns the controller test for a resource
def controller_test(resource)
  "test/controllers/#{resource}_controller_test.rb"
end

# Returns all tests related to a resource
def resource_tests(resource)
  integration_tests(resource) << controller_test(resource)
end
