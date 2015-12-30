require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rspec"
require "baza_models"
require "factory_girl"

Dir.foreach("spec/test_classes") do |file|
  require "test_classes/#{file}" if file.end_with?(".rb")
end

Dir.foreach("spec/factories") do |file|
  require "factories/#{file}" if file.end_with?(".rb")
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
