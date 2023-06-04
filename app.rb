ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"])

class App < Sinatra::Base
  use Sentry::Rack::CaptureExceptions

  configure do
    Sentry.init do |config|
      config.enabled_environments = %w[production]
    end
  end

  get "/" do
    "It works"
  end

  get "/play" do
    @input = params[:input]
    slim :play
  end

  post "/run" do
    input = params[:input]

    output = App.run_script(input)

    { output: output }.to_json
  end

  # @param [String] code
  # @return [String]
  def self.run_script(code)
    mock_stdout = StringIO.new
    $stdout = mock_stdout

    initialize_rubicure

    Object.new.instance_eval do
      code.each_line do |line|
        line = line.strip
        next if line.empty?

        puts "> #{line}"
        eval(line)
        puts ""
      end

      mock_stdout.string.strip
    end

  ensure
    $stdout = STDOUT
  end

  def self.initialize_rubicure
    Rubicure::Girl.sleep_sec = 0

    # rollback state
    Rubicure::Girl.names.each do |girl_name|
      girl = Rubicure::Girl.find(girl_name)
      girl.humanize!
      girl.rollback if girl.respond_to?(:rollback)
    end
  end
  private_class_method :initialize_rubicure
end
