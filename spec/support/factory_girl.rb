require 'rspec'
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  FactoryGirl.find_definitions

  config.before(:suite) do
    begin
      FactoryGirl.lint
    end
  end
end
