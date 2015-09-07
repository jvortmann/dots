# Dots

If you are unsure about how to setup your environment, this is a good start.

Here you will find reasonable setup for *git*, *ag*, *ctags*, *fish*, *gem*, *inputrc*, *irb*, *iterm* and *tmux*.
You will also find some scripts to setup a Mac for development (apps, keyboard config, etc) and applications in general.

I hope you enjoy :)

This repo is meant to be shared and reused.

##  Setup

### Symlinks

To setup the config files on your home directory run the following:

```sh
./symlink.sh  # setup and symlinks
```

### Applications

There is a script to [install applications](osx/install-apps.sh), command line utilities and fonts listed on [Brewfile](osx/Brewfile) and also a script to [download widgets](osx/download-widgets.sh).

```sh
./osx/install-apps.sh       # install apps, command line utilities and fonts
./osx/download-widgets.sh   # download widgets to ~/Downloads
```

### Mac OSX

There is a script to to setup Mac OSX for development on [configure osx] (osx/configure-osx.sh). It setups a lot of things: computer name, keyboard speed, remap capslock to control, spaces, shortcuts, etc. Take a look at the  script for all configuration.

```sh
./configure-osx.sh  # configure a Mac machine
```

### Fish

To setup fish shell after it is installed run the following:

```sh
./setup-fish.sh   # creates the config folders and set fish as default shell
```
