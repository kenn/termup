#!/usr/bin/env ruby
require 'rubygems'
require 'appscript'
require 'yaml'

module Termup
  class Base
    include Appscript

    def initialize(project)
      @terminal = app('Terminal')
      tabs = YAML.load(File.read("#{TERMUP_DIR}/#{project}.yml"))
      tabs.each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first
        cmds = [cmds].flatten
        tab = new_tab
        cmds.each do |cmd|
          @terminal.do_script(cmd, :in => tab)
        end
      end
    end

    def new_tab
      if @got_first_tab_already
        app("System Events").application_processes["Terminal.app"].keystroke("t", :using => :command_down)
      end
      @got_first_tab_already = true
      sleep 0.01 # Allow some time to complete opening a new tab
      @terminal.windows[1].tabs.last.get
    end
  end
end
