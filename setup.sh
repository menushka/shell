#!/bin/bash

# Check if Zsh is installed
if ! command -v zsh &> /dev/null; then
  echo "Zsh is not installed. Installing Zsh..."
  
  # Install Zsh on macOS or Linux
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    brew install zsh
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (Debian-based)
    sudo apt update && sudo apt install -y zsh
  else
    echo "Unsupported OS type. Exiting..."
    exit 1
  fi
else
  echo "Zsh is already installed."
fi

# Change the default shell to Zsh if it's not already the default
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing the default shell to Zsh..."
  chsh -s "$(which zsh)"
else
  echo "Zsh is already the default shell."
fi

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is not installed. Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme if not installed
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Powerlevel10k theme is not installed. Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "Powerlevel10k is already installed."
fi

# Set Zsh theme to Powerlevel10k in .zshrc
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
  echo "Setting Powerlevel10k as the default theme in .zshrc..."
  
  # Check if the OS is macOS or Linux
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
  fi
  
else
  echo "Powerlevel10k is already set as the default theme."
fi

# Download and copy the Powerlevel10k config file from the GitHub repo
P10K_URL="https://raw.githubusercontent.com/menushka/shell/refs/heads/master/.p10k.zsh?token=$TOKEN"

echo "Downloading Powerlevel10k config file from GitHub..."
if curl -fsSL "$P10K_URL" -o "$HOME/.p10k.zsh"; then
  echo "Powerlevel10k config file successfully downloaded and copied to home directory."
else
  echo "Failed to download Powerlevel10k config file. Please check the URL."
fi

# Ensure .zshrc is sourcing .p10k.zsh for Powerlevel10k configuration
if ! grep -q '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' "$HOME/.zshrc"; then
  echo "Adding Powerlevel10k config source to .zshrc..."
  echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> "$HOME/.zshrc"
else
  echo "Powerlevel10k config is already sourced in .zshrc."
fi

echo "Setup completed!"
