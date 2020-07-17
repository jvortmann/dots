# Dots

If you are unsure about how to setup your environment, this is a good start.

Here you will find reasonable setup for **ag**, **ctags**, **fish**, **gem**, **git**, **guard**, **inputrc**, **irb**, **iterm**, **osx**, **tmux** and **zsh**.
You will also find some scripts to setup a Mac for development (apps, keyboard config, etc) and applications in general.

I hope you enjoy :)

This repo is meant to be shared and reused.

##  Setup

To setup everything at once, run the folowwing:

```sh
./setup.sh "computer_name" "User Name" "user@email.com" # configure everything
```

##  Individual setup
If you wish to setup just some of the configs individually, use the follwoing instructions.

### Symlinks

To setup the config files on your home directory run the following:

```sh
./symlink.sh  # setup symlinks
```

### Applications

There is a script to [install applications](osx/install-apps.sh), command line utilities and fonts listed on [Brewfile](osx/Brewfile) and also a script to [download widgets](osx/download-widgets.sh).

```sh
cd osx/
./install-apps.sh       # install apps, command line utilities and fonts
./download-widgets.sh   # download widgets to ~/Downloads
```

### Mac OSX

There is a script to to setup Mac OSX for development on [configure osx] (osx/configure-osx.sh). It setups a lot of things: computer name, keyboard speed, remap capslock to control, spaces, shortcuts, etc. Take a look at the  script for all configuration.

```sh
cd osx/
./configure-osx.sh "computer_name" # configure a Mac machine
```

### Zsh

To setup zsh shell after it is installed run the following:

```sh
./setup-zsh.sh   # creates the config folders and set zsh as default shell
```

### Tmux

To setup tmux after it is installed run the following:

```sh
./setup-tmux.sh   # creates the plugin manager folder and clone it
```

### Setup Git user and email

To setup git user and email after the symlink is in place:

```sh
./setup-git-user.sh "User Name" "user@email.com" # configure git user and email
```

### Setup Tools

To setup the available tools (e.g. asdf, iex):

```sh
./setup_tools.sh # runs the setup file for each available tool
```