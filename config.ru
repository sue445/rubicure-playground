ENV["RACK_ENV"] ||= "development"

if ENV["RACK_ENV"] == "development"
  require "rack/unreloader"
  Unreloader = Rack::Unreloader.new(subclasses: "Sinatra::Base", autoload: true){ App }
  Unreloader.require "./app.rb"
  Unreloader.record_dependency("views")

  run Unreloader
else
  require "./app"
  run App
end
