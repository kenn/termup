module Termup
  class Base
    def initialize(project, process)
      @config = YAML.load_file(Termup::Dir.join("#{project}.yml"))
      @options = @config['options'] || {}
      @tabs = @config['tabs'] || {}
      @process = process
      @lines = []
    end

    def start
      script = <<-JS.gsub(/^\s+/, '')
        var app = Application(#{@process.pid});
        var se = Application('System Events');
        app.activate();
        #{@lines.join(";\n")}
      JS
      ExecJS.exec script

    rescue ExecJS::RuntimeError => e
      script.split("\n").each.with_index do |line, i|
        index = (i+1).to_s.rjust(3)
        puts "#{index}: #{line}"
      end
      puts e.message
    end

    protected

    def hit(key, *using)
      # activate
      using = using.map{|i| i.to_s.gsub(/_/,' ') }
      case key
      when Integer
        @lines << "se.keyCode(#{key}, { using: #{using} })"
      when String
        @lines << "se.keystroke('#{key}', { using: #{using} })"
      end
    end
  end
end
