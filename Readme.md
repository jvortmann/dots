# Dots

If you are unsure about how to setup your environment, this is a good start.

Here you will find reasonable setup for *git*, *ag*, *ctags*, *fish*, *gem*, *inputrc*, *irb*, *iterm* and *tmux*.
You will also find some scripts to setup a Mac for development (apps, keyboard config, etc) and applications in general.

I hope you enjoy :)

This repo is meant to be shared and reused.

##  Setup

### Symlinks

Run `./symlink.sh` to setup the config files on your home directory.

### Applications

Run `` to [install applications](osx/install-apps.sh), command line utilities and fonts listed on [Brewfile](osx/Brewfile).
There is also a script to [download widgets](osx/download-widgets.sh).

```
./osx/install-apps.sh       # install apps, command line utilities and fonts
./osx/download-widgets.sh   # download widgets to ~/Downloads
```

### Mac OSX

Run `./configure-osx.sh` to setup Mac OSX for development. It setups a lot of things: computer name, keyboard speed, remap capslock to control, spaces, shortcuts, etc. Take a look at [configure osx] (osx/configure-osx.sh) script for all configuration.

### Fish

Run `./setup-fish.sh` to setup fish shell after it is installed.
