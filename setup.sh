#!/bin/bash

# Prompt user for missing Git variables
read -p "Enter Git Author Name: " GIT_AUTHOR_NAME
read -p "Enter Git Author Email: " GIT_AUTHOR_EMAIL
read -p "Enter Git Username: " gitUsername

# Set Git configuration
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"

# Enable Git password caching
git config --global credential.helper osxkeychain

# Make `git pull` only in fast-forward mode
git config --global pull.ff only

if [ -n "$GIT_AUTHOR_EMAIL" ]; then
    # --> Notify
    echo "Generating SSH Key..."
    # --> Generate SSH Key
    ssh-keygen -t rsa -C "$GIT_AUTHOR_EMAIL"
    # --> Start SSH agent
    eval "$(ssh-agent -s)"
     # --> Add SSH Config file
    touch "$HOME/.ssh/config"
    echo "Host *" >> "$HOME/.ssh/config"
    echo " AddKeysToAgent yes" >> "$HOME/.ssh/config"
    echo " UseKeychain yes" >> "$HOME/.ssh/config"
    echo " IdentityFile ~/.ssh/id_rsa" >> "$HOME/.ssh/config"
     # --> Add SSH key locally
    ssh-add --apple-use-keychain "$HOME/.ssh/id_rsa"
     # --> GitHub SSH Key config
    if [ -n "$gitUsername" ] && [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        echo "Add this SSH Public Key on GitHub: https://github.com/settings/keys"
        # --> Notify
        echo "Copying SSH Public Key to Clipboard..."
        pbcopy < "$HOME/.ssh/id_rsa.pub"
    else
        echo "Cannot execute: pbcopy < $HOME/.ssh/id_rsa.pub"
        echo "Try to run this command manually"
    fi
else
    echo "No SSH Key configured due to missing Git User Email!"
fi

mkdir "$HOME/Desktop/Screenshots"
