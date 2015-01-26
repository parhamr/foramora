require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/tmp/'
  add_filter '/log/'
end
