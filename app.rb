ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"])

class App < Sinatra::Base
  get "/" do
    "It works"
  end

  get "/play" do
    slim :play
  end

  post "/run" do
    input = params[:input]

    # TODO: WIP
    { output: input }.to_json
  end

  # @param [String] code
  # @return [String]
  def self.run_script(code)
    mock_stdout = StringIO.new
    $stdout = mock_stdout

    Rubicure::Girl.sleep_sec = 0

    code.each_line do |line|
      line = line.strip
      next if line.empty?

      puts "> #{line}"
      eval(line)
      puts ""
    end

    mock_stdout.string

  ensure
    $stdout = STDOUT
  end
end
