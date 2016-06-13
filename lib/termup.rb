require 'yaml'
require 'pathname'
require 'execjs/runtimes/jxa'

ExecJS.runtime = ExecJS::Runtimes::JXA

module Termup
  Dir = Pathname.new(ENV['HOME']).join('.config/termup')

  autoload :Base,     'termup/base'
  autoload :Cli,      'termup/cli'
  autoload :Iterm,    'termup/iterm'
  autoload :Process,  'termup/process'
  autoload :Terminal, 'termup/terminal'
end
