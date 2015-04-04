Termup
======

Automate opening up terminal tabs (or split panes) with a set of routine commands.

It's the easiest way to get started for your projects every day.

Compatible with Terminal.app and iTerm 2 on OSX 10.6 - 10.9 and Ruby 1.8.7 - 2.2.

![Split Panes](https://github.com/kenn/termup/raw/master/images/split_panes.png)

**For iTerm 1:** Termup 2.0 and up is not compatible with iTerm 1. Install 1.3.1 by `gem install termup -v=1.3.1`

Installation
------------

```sh
$ gem install termup
```

Note that you need to prepend `sudo` if you're using the OSX pre-installed Ruby.

### When failed to build rb-appscript

Termup has a dependency on the `rb-appscript` gem to bridge AppleScript, but `rb-appscript` is no longer maintained by the original author, and newer Ruby versions won't build it.

To fix it, clone [the forked version](https://github.com/kenn/appscript), then run the following commands to install patched version of rb-appscript.

```sh
$ cd appscript/rb-appscript/trunk/
$ gem build rb-appscript.gemspec
$ gem install rb-appscript-0.6.1.gem
```

Usage
-----

### Getting Started ###

Call the following command:

```sh
$ termup create myproject
```

This will create a new project at `~/.config/termup/myproject.yml`. Edit the file:

```sh
$ termup edit myproject
```

And now you're good to go:

```sh
$ termup start myproject
```

### YAML Syntax ###

```yaml
# ~/.config/termup/myproject.yml
---
tabs:
  tab1:
    - cd ~/projects/foo
    - git status
    - subl .
  tab2:
    - mysql -u root
    - show databases;
  tab3:
    - cd ~/projects/foo
    - tail -f log/development.log
  tab4:
    - cd ~/projects/foo
    - autotest
options:
  iterm:
    width: 2
    height: 2
```

Tabs can contain a single command, or YAML arrays to execute multiple commands.

### Shortcut ###

Commands have a shortcut for even fewer keystrokes.

```sh
$ termup s myproject
```

That's equivalent to `termup start myproject`.

iTerm 2 Split Pane Support
--------------------------

There are two options to deal with split panes on iTerm 2: `--iterm_basic` and `--iterm_advanced`

### --iterm_basic

```sh
termup create myproject --iterm_basic
```

This will generate additional options in the config file:

```yaml
options:
  iterm:
    width: 2
    height: 2
```

The setting above will generate four panes in the following layout.

    #################
    #       #       #
    #   1   #   3   #
    #       #       #
    #################
    #       #       #
    #   2   #   4   #
    #       #       #
    #################

### --iterm_advanced

```sh
termup create myproject --iterm_advanced
```

This will generate a config file in an advanced format:

```yaml
# COMMENT OF SCRIPT HERE
---
tabs:
  pane1:
    commands:
      - echo pane1
    layout:
      - split_vertically
  pane2:
    commands:
      - echo pane2
    layout:
      - split_horizontally
  pane3:
    commands:
      - echo pane3
    layout:
      - split_horizontally
  pane4:
    commands:
      - echo pane4
```

The setting above will generate four panes in the following layout.

    #################
    #       #       #
    #       #   2   #
    #       #       #
    #       #########
    #       #       #
    #   1   #   3   #
    #       #       #
    #       #########
    #       #       #
    #       #   4   #
    #       #       #
    #################

Available layout commands:

```ruby
new_tab
close_tab
goto_previous_tab
goto_next_tab
goto_previous_pane
goto_next_pane
split_vertically
split_horizontally
go_left
go_right
go_down
go_up
```
