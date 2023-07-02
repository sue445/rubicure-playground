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
    @font_size = params[:font_size] || 14
    @readonly = params[:readonly]
    @editor_height = params[:editor_height]

    headers(
      {
        "Content-Security-Policy" => "frame-ancestors 'self' http://* https://* http://localhost:* https://sue445.github.io",
        "Cross-Origin-Resource-Policy" => "cross-origin",
        "Cross-Origin-Embedder-Policy" => "credentialless",
      }
    )
    slim :play
  end

  post "/run" do
    input = params[:input]

    output, is_error = App.run_script(input)

    { output: output, is_error: is_error }.to_json
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
        ret = eval(line)
        puts "#=> #{ret}".strip
        puts ""
      end

      [mock_stdout.string.strip, false]
    end

  rescue => error
    [format_backtrace(error), true]

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

  # @param error [Exception]
  # @return [String]
  def self.format_backtrace(error)
    lines = ["#{error.class}: #{error.message}"]
    error.backtrace.each_with_index do |line, index|
      lines << "#{index + 1}: #{line}"
    end

    lines.join("\n")
  end
  private_class_method :format_backtrace
end
