require 'appscript'
require 'yaml'

module Termup
  class Base
    ITERM1 = /^0\.10/
    ITERM2 = /^0\.20/

    include Appscript

    def initialize(project)
      @apps = app("System Events").application_processes
      @frontmost = @apps.get.select{|i| i.frontmost.get }.map{|i| i.name.get }.first
      return unless ["Terminal", "iTerm"].include?(@frontmost)
      @terminal = app(@frontmost)

      @project = YAML.load(File.read("#{TERMUP_DIR}/#{project}.yml"))

      # Split panes for iTerm
      split_panes if @frontmost == "iTerm" and @project['options']['iterm']

      @project['tabs'].each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first
        cmds = [cmds].flatten
        tab = new_tab
        cmds.each do |cmd|
          if iterm2?
            @terminal.current_terminal.current_session.write(:text => "#{cmd}")
          else
            @terminal.do_script(cmd, :in => tab)
          end
        end
      end
    end

    def new_tab
      if @got_first_tab_already
        if iterm2?
          @apps[@frontmost].keystroke("]", :using => :command_down)
        else
          @apps[@frontmost].keystroke("t", :using => :command_down)
        end
      end
      @got_first_tab_already = true
      sleep 0.01 # Allow some time to complete opening a new tab
      @terminal.windows[1].tabs.last.get if terminal?
    end

    def split_panes
      # Virtical splits
      (@project['options']['iterm']['width'] - 1).times do |i|
        @apps[@frontmost].keystroke("d", :using => :command_down)
      end
      # Back to home
      @apps[@frontmost].keystroke("]", :using => :command_down)
      # Horizontal splits
      @project['options']['iterm']['width'].times do |i|
        (@project['options']['iterm']['height'] - 1).times do |i|
          @apps[@frontmost].keystroke("d", :using => [ :command_down, :shift_down ])
        end
        # Move to the right
        @apps[@frontmost].keystroke("]", :using => :command_down)
      end
    end

    def terminal?
      @frontmost == "Terminal"
    end

    def iterm1?
      @frontmost == "iTerm" and @terminal.version.get =~ ITERM1
    end

    def iterm2?
      @frontmost == "iTerm" and @terminal.version.get =~ ITERM2
    end
  end
end
