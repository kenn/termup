module Termup
  class Terminal < Base
    def start
      # Setting up tabs / panes
      @tabs.each.with_index do |(tabname, values), index|
        values.each do |command|
          @lines << "app.doScript('#{command}', { in: app.windows[0].tabs.last() })"
        end

        if index < @tabs.size - 1
          layout :new_tab
          sleep 0.01 # Allow some time to complete opening a new tab
        else
          layout :goto_next_tab # Back home
        end
      end

      super
    end

    def layout(command)
      case command.to_sym
      when :new_tab             then hit 't', :command_down
      when :close_tab           then hit 'w', :command_down
      when :goto_previous_tab   then hit '[', :command_down, :shift_down
      when :goto_next_tab       then hit ']', :command_down, :shift_down
      else
        abort "Unknown Terminal.app command: #{command}"
      end
    end
  end
end
