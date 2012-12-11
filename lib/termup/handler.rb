require 'appscript'

module Termup
  class Handler
    def app(*args)
      Appscript.app(*args)
    end

    def activate
      app_process.activate
    end

    def keystroke(*args)
      activate
      app('System Events').keystroke(*args)
    end

    def key_code(*args)
      activate
      app('System Events').key_code(*args)
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
  end
end
