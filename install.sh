#!/usr/bin/env bash

DOTFILES="$(pwd)"
RUBY_VERSION="2.7.4"
NPM_VERSION="12"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

load_rources() {
    . ~/.nvm/nvm.sh
    . ~/.profile
    . ~/.bashrc
    . $(brew --prefix nvm)/nvm.sh
}

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

get_linkables() {
    find -H "$DOTFILES" -maxdepth 3 -name '*.symlink'
}

setup_symlinks() {
    title "Creating symlinks"

    for file in $(get_linkables) ; do
        target="$HOME/.$(basename "$file" '.symlink')"
        if [ -e "$target" ]; then
            info "~${target#$HOME} already exists... Skipping."
        else
            info "Creating symlink for $file"
            ln -s "$file" "$target"
        fi
    done
}

setup_homebrew() {
    title "Setting up Homebrew"

    if test ! "$(command -v brew)"; then
        info "Homebrew not installed. Installing."
        # Run as a login shell (non-interactive) so that the script doesn't pause for user input
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # install brew dependencies from Brewfile
    brew bundle
}

setup_nvm() {
    title "Setting up NVM"

    if test ! "$(command -v nvm)"; then
        info "NVM not installed. Installing."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash --login
    fi
}

setup_node() {
    title "Setting up node"

    load_rources
    # install npm version
    nvm install $NPM_VERSION
    # set npm version as default 
    nvm alias default $NPM_VERSION

    npm install -g yarn
}

setup_rn() {
    title "Setting up React Native"
    
    load_rources
    # install react-native-cli
    npm install -g react-native-cli

    info "Setting up cocoapods"
    sudo gem install cocoapods
    gem install -n /usr/local/bin/ bundler
    gem install -n /usr/local/bin/ fastlane
}

setup_rvm() {
    title "Setting up RVM"

    if test ! "$(command -v rvm)"; then
        info "RVM not installed. Installing."
        # Run as a login shell (non-interactive) so that the script doesn't pause for user input
        curl -sSL https://get.rvm.io | bash --login
    fi

    # install ruby version
    rvm install $RUBY_VERSION
    # set ruby version as default
    rvm alias create default $RUBY_VERSION
}

setup_build_agent() {
    title "Setting up the build agent"

    info "Android bundle install"
    cd "$CODE_DIR/android"
    bundle install
    fastlane install_plugins

    info "iOS bundle install"
    cd "$CODE_DIR/ios"
    bundle install
    fastlane install_plugins
    fastlane cert
}

setup_macos() {
    title "Configuring macOS"
    if [[ "$(uname)" == "Darwin" ]]; then

        echo "Finder: show all filename extensions"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool false

        echo "show hidden files by default"
        defaults write com.apple.Finder AppleShowAllFiles -bool false

        echo "only use UTF-8 in Terminal.app"
        defaults write com.apple.terminal StringEncodings -array 4

        echo "expand save dialog by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

        echo "show the ~/Library folder in Finder"
        chflags nohidden ~/Library

        echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
        defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

        echo "Enable subpixel font rendering on non-Apple LCDs"
        defaults write NSGlobalDomain AppleFontSmoothing -int 2

        echo "Use current directory as default search scope in Finder"
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

        echo "Show Path bar in Finder"
        defaults write com.apple.finder ShowPathbar -bool true

        echo "Show Status bar in Finder"
        defaults write com.apple.finder ShowStatusBar -bool true

        echo "Disable press-and-hold for keys in favor of key repeat"
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

        echo "Set a blazingly fast keyboard repeat rate"
        defaults write NSGlobalDomain KeyRepeat -int 1

        echo "Set a shorter Delay until key repeat"
        defaults write NSGlobalDomain InitialKeyRepeat -int 15

        echo "Enable tap to click (Trackpad)"
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

        echo "Kill affected applications"

        for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
    else
        warning "macOS not detected. Skipping."
    fi
}

setup_shell() {
    title "Configuring shell"

    [[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"
    if ! grep "$zsh_path" /etc/shells; then
        info "adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
        info "default shell changed to $zsh_path"
    fi
}

case "$1" in
    link)
        setup_symlinks
        ;;
    homebrew)
        setup_homebrew
        ;;
    shell)
        setup_shell
        ;;
    nvm)
        setup_nvm
        ;;
    node)
        setup_node
        ;;
    rvm)
        setup_rvm
        ;;
    rn)
        setup_rn
        ;;
    macos)
        setup_macos
        ;;
    agent)
        setup_build_agent
        ;;
    all)
        setup_symlinks
        setup_homebrew
        setup_shell
        setup_nvm
        setup_node
        setup_rvm
        setup_rn
        setup_macos
        ;;
    *)
        echo -e $"\nUsage: $(basename "$0") {link|homebrew|shell|nvm|node|rvm|rn|macos|agent|all}\n"
        exit 1
        ;;
esac

echo -e
success "Done."
