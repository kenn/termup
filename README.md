Termup
======

Initialize your terminal tabs (or split panes) with preset commands.

Compatible with Terminal.app, iTerm and iTerm2 on Mac OS X 10.6 and Ruby 1.9.2 / 1.8.7.

Ever wanted to automate everyday routine on the terminal in a simple way? Termup is right here for you.

![Split Panes](https://github.com/kenn/termup/raw/master/images/split_panes.png)

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
        - cd ~/projects/foo
        - git status
        - mate .
      - tab2:
        - mysql -u root
        - show databases;
      - tab3:
        - cd ~/projects/foo
        - tail -f log/development.log
      - tab4:
        - cd ~/projects/foo
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
