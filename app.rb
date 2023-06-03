ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"])

class App < Sinatra::Base
  get "/" do
    "It works"
  end

  get "/play" do
    slim :play
  end
end
