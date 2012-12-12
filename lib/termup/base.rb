require 'yaml'

module Termup
  class Base
    def initialize(project)
      @handler = Termup::Handler.new

      config = YAML.load(File.read("#{TERMUP_DIR}/#{project}.yml"))
      @tabs = config['tabs']

      # Config file compatibility checking
      if @tabs.is_a?(Array) and @tabs.first.is_a?(Hash)
        abort 'YAML syntax for config has been changed. See https://github.com/kenn/termup for details.'
      end

      @options = config['options'] || {}
      @iterm_options = @options['iterm']

      # Split panes for iTerm 2
      split_panes if @handler.iterm? and @iterm_options

      # Setting up tabs / panes
      @tabs.each_with_index do |(tabname, values), index|
        # Set tab title
        @handler.set_property(:name, tabname)

        # Run commands
        (advanced_iterm? ? values['commands'] : values).each do |command|
          @handler.run command
        end

        # Layout
        if advanced_iterm?
          values['properties'].each do |key, value|
            @handler.set_property(key, value)
          end if values['properties']

          values['layout'].each do |command|
            layout command
          end if values['layout']
        else
          # Move to next
          if @iterm_options
            layout :goto_next_pane
          else
            if index < @tabs.size - 1
              layout :new_tab
              sleep 0.01 # Allow some time to complete opening a new tab
            else
              layout :goto_next_tab # Back home
            end
          end
        end
      end
    end

    def split_panes
      width, height = @iterm_options['width'], @iterm_options['height']
      return unless width and height

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

    def advanced_iterm?
      unless defined?(@advanced_iterm)
        @advanced_iterm = case @tabs.values.first
        when Hash   then true
        when Array  then false
        else
          abort 'invalid YAML format'
        end
        abort 'advanced config only supported for iTerm' if @advanced_iterm and !@handler.iterm?
      end
      @advanced_iterm
    end

    def layout(command)
      @handler.layout(command)
    end
  end
end
