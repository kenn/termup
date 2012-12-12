require 'appscript'

module Termup
  class Handler
    def app(*args)
      Appscript.app(*args)
    end

    def run(command)
      if terminal?
        app_process.do_script(command, :in => app_process.windows[1].tabs.last.get)
      else
        app_process.current_terminal.current_session.write(:text => command)
      end
    end

    def set_property(key, value)
      if iterm?
        app_process.current_terminal.current_session.send(key).set(value)
      else
        # No-op for terminal for now
      end
    end

    def activate
      app_process.activate
    end

    def hit(key, *using)
      activate
      case key
      when Integer
        app('System Events').key_code key, using && { :using => using }
      when String
        app('System Events').keystroke key, using && { :using => using }
      end
    end

    def terminal?
      app_name == 'Terminal'
    end

    def iterm?
      app_name == 'iTerm'
    end

    def app_name
      @app_name ||= app_process.name.get
    end

    def app_process
      @app_process ||= app.by_pid(term_pid)
    end

    def term_pid
      return @term_pid if @term_pid

      pid = Process.ppid

      # Go up the process tree to find term-like process
      100.times do
        ppid = `ps -p #{pid} -o ppid=`.strip.to_i

        abort 'terminal pid not found!' if ppid == 1

        if term_like_pids.include?(ppid)
          @term_pid = ppid
          break
        end

        pid = ppid
      end

      @term_pid
    end

    def term_like_pids
      @term_like_pids ||= `ps x | grep Term`.split("\n").reject{|i| i =~ /grep/ }.map{|i| i.match(/^\d+/).to_s.to_i }
    end

    def layout(command)
      if iterm?
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
      else
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
end
