Termup
======

Initialize your terminal tabs with preset commands.

Compatible with Terminal.app on Mac OS X 10.6 and Ruby 1.9.2.

Installation
------------

    $ gem install termup

Usage
-----

### Getting Started ###

Call the following command:

    $ termup create new_project

This will create a new project at `~/.config/termup/new_project.yml`. Edit the file:

    $ termup edit new_project

And now you're good to go:

    $ termup start new_project

### YAML Syntax ###

    # ~/.config/termup/new_project.yml
    ---
    tabs:
      - tab1:
        - cd ~/foo/bar
        - git status
      - tab2:
        - mysql -u root
        - show databases;
      - tab3: echo "hello world"
      - tab4:
        - cd ~/foo/project
        - autotest
    options:
      iterm:
        width: 2
        height: 2

Tabs can contain a single command, or YAML arrays to execute multiple commands.

### Shortcut ###

Commands have a shortcut for even fewer keystrokes.

    $ termup s new_project

That's equivalent to `termup start new_project`.

### iTerm 2 Split Pane Support ###

Specify iTerm option to use split pane.

    options:
      iterm:
        width: 2
        height: 2

The setting above turns to:

    #################
    #       #       #
    #   1   #   3   #
    #       #       #
    #################
    #       #       #
    #   2   #   4   #
    #       #       #
    #################
