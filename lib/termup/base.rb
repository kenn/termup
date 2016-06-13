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
      script = <<-JS
        var app = Application(#{@process.pid});
        var se = Application('System Events');
        app.activate();
        #{@lines.join(';')}
      JS
      ExecJS.exec script
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
