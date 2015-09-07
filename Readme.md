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

Run `./osx/install-apps.sh` to install applications, command line utilities and fonts listed on [Brewfile](osx/Brewfile)[Install Apps](osx/install-apps.sh).
There is also a script to download widgets: `./osx/download-widgets.sh` [Download Widgets](osx/download-widgets.sh)

### Mac OSX

Run `./configure-osx.sh` to setup Mac OSX for development. It setups a lot of things: computer name, keyboard speed, remap capslock to control, spaces, shortcuts, etc. Take a look at [Configure OSX] (osx/configure-osx.sh) for all configuration.

### Fish

Run `./setup-fish.sh` to setup fish shell after it is installed.
