Termup
======

Automate opening up terminal tabs (or split panes) with a set of routine commands.

It's the easiest way to get started for your projects every day.

Compatible with Terminal.app and iTerm 2 on Mac OS X 10.6 - 10.8 and Ruby 1.8.7 - 1.9.3.

![Split Panes](https://github.com/kenn/termup/raw/master/images/split_panes.png)

**iTerm 1 users** the current version is not compatible with iTerms 1. Use v1.3.1 - `gem install termup -v=1.3.1`

Installation
------------

```sh
$ gem install termup
```

Note that you need to prepend `sudo` if you're using the OSX pre-installed Ruby.

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

### iTerm 2 Split Pane Support ###

Specify iTerm option to use split pane.

```yaml
options:
  iterm:
    width: 2
    height: 2
```

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

Enjoy!
