require 'appscript'
require 'yaml'

module Termup
  class Base
    ITERM1 = /^0\.10/
    ITERM2 = /^1.0/

    include Appscript

    def initialize(project)
      @apps = app('System Events').application_processes
      @frontmost = @apps.get.select{|i| i.frontmost.get }.map{|i| i.name.get }.first
      return unless ['Terminal', 'iTerm'].include?(@frontmost)
      @terminal = app(@frontmost)

      @project = YAML.load(File.read("#{TERMUP_DIR}/#{project}.yml"))

      # Split panes for iTerm 2 layout with iterm commands
      return split_panes2 if iterm2? and @project['options']['iterm2']

      # Split panes for iTerm 2
      split_panes if iterm2? and @project['options']['iterm']

      @project['tabs'].each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first
        cmds = [cmds].flatten
        tab = new_tab
        cmds.each do |cmd|
          if terminal?
            @terminal.do_script(cmd, :in => tab)
          else
            @terminal.current_terminal.current_session.write(:text => "#{cmd}")
          end
        end
      end
    end

    def new_tab
      if @got_first_tab_already
        if iterm2?
          @apps[@frontmost].keystroke(']', :using => :command_down)
        else
          @apps[@frontmost].keystroke('t', :using => :command_down)
        end
      end
      @got_first_tab_already = true
      sleep 0.01 # Allow some time to complete opening a new tab
      @terminal.windows[1].tabs.last.get if terminal?
    end

    def split_panes
      # Virtical splits
      (@project['options']['iterm']['width'] - 1).times do |i|
        @apps[@frontmost].keystroke('d', :using => :command_down)
      end
      # Back to home
      @apps[@frontmost].keystroke(']', :using => :command_down)
      # Horizontal splits
      @project['options']['iterm']['width'].times do |i|
        (@project['options']['iterm']['height'] - 1).times do |i|
          @apps[@frontmost].keystroke('d', :using => [ :command_down, :shift_down ])
        end
        # Move to the right
        @apps[@frontmost].keystroke(']', :using => :command_down)
      end
    end

    def split_panes2
      @project['tabs'].each_with_index do |hash, index|
        tabname = hash.keys.first
        tab = hash[tabname]
        @terminal.current_terminal.current_session.name.set(tabname)

        if tab['background']
          @terminal.current_terminal.current_session.background_color.set(tab['background'])
        end

        if tab['foreground']
          @terminal.current_terminal.current_session.foreground_color.set(tab['foreground'])
        end

        if tab['transparency']
          @terminal.current_terminal.current_session.transparency.set(tab['transparency'])
        end

        tab['commands'].each do |cmd|
          @terminal.current_terminal.current_session.write(:text => "#{cmd}")
        end

        tab['layout'] ||= []
        if tab['layout'].empty? and index < @project['tabs'].size - 1
          tab['layout'] << 'new_tab' 
        end

        tab['layout'].each do |cmd|
          case cmd
          when 'new_tab'
            @apps[@frontmost].keystroke('t', :using => [ :command_down ] )
          when 'close_tab'
            @apps[@frontmost].keystroke('w', :using => [ :command_down ] )
          when 'go_to_previous_tab'
            @apps[@frontmost].key_code(123, :using => [ :command_down ] )
          when 'go_to_next_tab'
            @apps[@frontmost].key_code(124, :using => [ :command_down ] )
          when 'split_horizontally'
            @apps[@frontmost].keystroke('d', :using => [ :command_down, :shift_down ] )
          when 'split_vertically'
            @apps[@frontmost].keystroke('d', :using => [ :command_down ] )
          when 'go_left'
            @apps[@frontmost].key_code(123, :using => [ :command_down, :option_down ] )
          when 'go_right'
            @apps[@frontmost].key_code(124, :using => [ :command_down, :option_down ] )
          when 'go_down'
            @apps[@frontmost].key_code(125, :using => [ :command_down, :option_down ] )
          when 'go_up'
            @apps[@frontmost].key_code(126, :using => [ :command_down, :option_down ] )
          else
            raise "Unknown iTerm2 command #{cmd}"
          end

          sleep 0.01
        end
      end
    end

    def terminal?
      @frontmost == 'Terminal'
    end

    def iterm1?
      @frontmost == 'iTerm' and @terminal.version.get =~ ITERM1
    end

    def iterm2?
      @frontmost == 'iTerm' and @terminal.version.get =~ ITERM2
    end
  end
end
