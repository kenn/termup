require 'yaml'

module Termup
  class Base
    def initialize(project)
      @handler = Termup::Handler.new
      @terminal = @handler.app_process

      project = YAML.load(File.read("#{TERMUP_DIR}/#{project}.yml"))
      @options = project['options']
      @tabs = project['tabs']

      # Compatibility checking
      if @tabs.is_a?(Array) and @tabs.first.is_a?(Hash)
        abort 'YAML syntax for config has been changed. See https://github.com/kenn/termup for details.'
      end

      # Split panes for iTerm 2 layout with iterm commands
      return split_panes2 if @handler.iterm? and @options['iterm2']

      # Split panes for iTerm 2
      split_panes if @handler.iterm? and @options['iterm']

      @tabs.each do |tabname, cmds|
        @terminal.current_terminal.current_session.name.set(tabname) if @handler.iterm?
        tab = new_tab
        cmds.each do |cmd|
          if @handler.terminal?
            @terminal.do_script(cmd, :in => tab)
          else
            @terminal.current_terminal.current_session.write(:text => cmd)
          end
        end
      end
    end

    def new_tab
      if @got_first_tab_already
        if @handler.iterm?
          @handler.keystroke(']', :using => :command_down)
        else
          @handler.keystroke('t', :using => :command_down)
        end
      end
      @got_first_tab_already = true
      sleep 0.01 # Allow some time to complete opening a new tab
      @terminal.windows[1].tabs.last.get if @handler.terminal?
    end

    def split_panes
      # Virtical splits
      (@options['iterm']['width'] - 1).times do |i|
        @handler.keystroke('d', :using => :command_down)
      end
      # Back to home
      @handler.keystroke(']', :using => :command_down)
      # Horizontal splits
      @options['iterm']['width'].times do |i|
        (@options['iterm']['height'] - 1).times do |i|
          @handler.keystroke('d', :using => [ :command_down, :shift_down ])
        end
        # Move to the right
        @handler.keystroke(']', :using => :command_down)
      end
    end

    def split_panes2
      @tabs.each_with_index do |(tabname, tab), index|
        @terminal.current_terminal.current_session.name.set(tabname)

        if tab['properties']
          tab['properties'].each do |key, value|
            @terminal.current_terminal.current_session.send(key).set(value)
          end
        end

        tab['commands'].each do |cmd|
          @terminal.current_terminal.current_session.write(:text => cmd)
        end

        tab['layout'] ||= []
        if tab['layout'].empty? and index < @tabs.size - 1
          tab['layout'] << 'new_tab' 
        end

        tab['layout'].each do |cmd|
          case cmd
          when 'new_tab'            then @handler.keystroke('t', :using => [ :command_down ] )
          when 'close_tab'          then @handler.keystroke('w', :using => [ :command_down ] )
          when 'go_to_previous_tab' then @handler.key_code(123, :using => [ :command_down ] )
          when 'go_to_next_tab'     then @handler.key_code(124, :using => [ :command_down ] )
          when 'split_horizontally' then @handler.keystroke('d', :using => [ :command_down, :shift_down ] )
          when 'split_vertically'   then @handler.keystroke('d', :using => [ :command_down ] )
          when 'go_left'            then @handler.key_code(123, :using => [ :command_down, :option_down ] )
          when 'go_right'           then @handler.key_code(124, :using => [ :command_down, :option_down ] )
          when 'go_down'            then @handler.key_code(125, :using => [ :command_down, :option_down ] )
          when 'go_up'              then @handler.key_code(126, :using => [ :command_down, :option_down ] )
          else
            raise "Unknown iTerm2 command #{cmd}"
          end

          sleep 0.01
        end
      end
    end
  end
end
