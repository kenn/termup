module Termup
  class Process
    attr_reader :pid

    def initialize
      lookup_pid
    end

    def terminal?
      app_name == 'Terminal'
    end

    def iterm?
      app_name == 'iTerm'
    end

    def app_name
      @app_name ||= ExecJS.eval "Application(#{@pid}).name()"
    end

    def lookup_pid
      pid = ::Process.ppid
      pids = []

      # Go up the process tree to find term-like process
      while pid > 1 do
        pids << pid if term_like_pids.include?(pid)
        pid = `ps -p #{pid} -o ppid=`.strip.to_i
      end

      abort 'terminal pid not found!' if pids.empty?

      @pid = pids.last
    end

    def term_like_pids
      @term_like_pids ||= `ps x | grep Term`.split("\n").reject{|i| i =~ /grep/ }.map{|i| i.match(/\d+/).to_s.to_i }
    end
  end
end
