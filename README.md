# Dotfiles

Welcome to Adil's whole world. This is a collection of zsh, git, homebrew, rvm, nvm etc...

### Installation

If on OSX, you will need to install the XCode CLI tools before continuing. To do so, open a terminal and type

```bash
➜ xcode-select --install
```

Then, clone the dotfiles repository anywhere you like on your machine.

```bash
➜ git clone https://github.com/adilbenmoussa/dotfiles.git
➜ cd dotfiles
➜ ./install.sh
```


The install script will perform a check to see if it is running on an OSX machine. If so, it will install Homebrew if it is not currently installed and will install the homebrew packages listed in [`Brewfile`](Brewfile). Then, it will run macos and change some OSX configurations. This file is pretty well documented and so it is advised that you __read through and comment out any changes you do not want__.

## ZSH Setup

ZSH is configured in the `zshrc.symlink` file, which will be symlinked to the home directory. The following occurs in this file:

* Set the `CODE_DIR` variable, pointing to the location where the code projects exist for exclusive autocompletion with the `c` command
* Recursively search the `$DOTFILES/zsh` directory for files ending in .zsh and source them
* Setup zplug plugin manager for zsh plugins and installed them.
* source a `~/.localrc` if it exists so that additional configurations can be made that won't be kept track of in this dotfiles repo. This is good for things like API keys, etc.
* And more...

## Change those constants 

* DEFAULT_GIT_BRANCH="development"
* RUBY_VERSION="2.7.4"
* NPM_VERSION="12"



## Questions

If you have questions, notice issues,  or would like to see improvements, please open a new [discussion](https://github.com/adilbenmoussa/discussions/new) and I'm happy to help you out!
