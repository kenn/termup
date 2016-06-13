module Termup
  class Iterm < Base
    def start
      split_panes if @options['iterm']

      # Setting up tabs
      @tabs.each.with_index do |(tabname, values), index|
        set_property(:name, tabname) # Set tab title

        if advanced_iterm?
          values['commands'].each do |command|
            run(command)
          end

          values['properties'].each do |key, value|
            set_property(key, value)
          end if values['properties']

          values['layout'].each do |command|
            layout command
          end if values['layout']
        else
          values.each do |command|
            run(command)
          end

          layout :goto_next_pane
        end
      end

      super
    end

    private

    def split_panes
      width, height = @options['iterm']['width'], @options['iterm']['height']
      return unless width && height

      (width - 1).times do
        layout :split_vertically
      end
      layout :goto_next_pane # Back home
      width.times do
        (height - 1).times do
          layout :split_horizontally
        end
        layout :goto_next_pane # Move to next, or back home
      end
    end

    def run(command)
      @lines << "app.currentWindow().currentSession().write({'text':'#{command}'})"
    end

    def set_property(key, value)
      value = value.inspect if value.is_a?(String)
      @lines << "app.currentWindow().currentSession().#{camelize(key)}.set(#{value})"
    end

    def advanced_iterm?
      unless defined?(@advanced_iterm)
        @advanced_iterm = case @tabs.values.first
        when Hash   then true
        when Array  then false
        else
          abort 'invalid YAML format'
        end
      end
      @advanced_iterm
    end

    def camelize(string)
      string.to_s.split('_').map.with_index{|s,index| index.zero? ? s : s.slice(0).upcase + s.slice(1..-1) }.join
    end

    def layout(command)
      case command.to_sym
      when :new_tab             then hit 't', :command_down
      when :close_tab           then hit 'w', :command_down
      when :goto_previous_tab   then hit '[', :command_down, :shift_down
      when :goto_next_tab       then hit ']', :command_down, :shift_down
      when :goto_previous_pane  then hit '[', :command_down
      when :goto_next_pane      then hit ']', :command_down
      when :split_vertically    then hit 'd', :command_down
      when :split_horizontally  then hit 'd', :command_down, :shift_down
      when :go_left             then hit 123, :command_down, :option_down
      when :go_right            then hit 124, :command_down, :option_down
      when :go_down             then hit 125, :command_down, :option_down
      when :go_up               then hit 126, :command_down, :option_down
      else
        abort "Unknown iTerm2.app command: #{command}"
      end
    end
  end
end
