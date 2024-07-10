#!/usr/bin/env bash
set -e

# Add Neovim as an alternative for vi
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60

# Add Neovim as an alternative for vim
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60

# Add Neovim as an alternative for the generic editor
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

# Set Neovim as the default editor
update-alternatives --set vi /usr/bin/nvim
update-alternatives --set vim /usr/bin/nvim
update-alternatives --set editor /usr/bin/nvim

# Set Neovim as the default editor for all users
echo "export EDITOR='/usr/bin/nvim'" | tee /etc/profile.d/editor.sh
echo "export VISUAL='/usr/bin/nvim'" | tee /etc/profile.d/visual.sh
