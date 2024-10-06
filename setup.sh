#!/bin/bash

# Function to check if a font is installed (works for both macOS and Ubuntu)
check_font_installed() {
  local font_name="$1"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check in the user's Library/Fonts folder on macOS
    if ls "$HOME/Library/Fonts/$font_name" &> /dev/null; then
      return 0
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check in the local fonts directory on Ubuntu
    if ls "$HOME/.local/share/fonts/$font_name" &> /dev/null; then
      return 0
    fi
  fi
  
  return 1
}

# Check if Homebrew is installed, if not, install it
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed."
fi

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

# Check if the fonts are already installed
if check_font_installed "MesloLGS NF Regular.ttf" && \
   check_font_installed "MesloLGS NF Bold.ttf" && \
   check_font_installed "MesloLGS NF Italic.ttf" && \
   check_font_installed "MesloLGS NF Bold Italic.ttf"; then
  echo "MesloLGS NF fonts are already installed."
else
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install MesloLGS NF font
    brew install font-meslo-lg-nerd-font

    echo "MesloLGS NF fonts installed."

    plutil -replace 'New Bookmarks.0.Normal Font' -string "MesloLGLNFM-Regular 11" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"

    echo "MesloLGS NF fonts set as default in iTerm2."

  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Create a local font directory if it doesn't exist
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    # Download the fonts
    curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -o "$FONT_DIR/MesloLGS NF Regular.ttf"
    curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -o "$FONT_DIR/MesloLGS NF Bold.ttf"
    curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Italic.ttf"
    curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -o "$FONT_DIR/MesloLGS NF Bold Italic.ttf"

    echo "MesloLGS NF fonts installed in $FONT_DIR."

    # Install fc-cache (fontconfig) if not installed
    if ! command -v fc-cache &> /dev/null; then
      echo "fc-cache not found. Installing fontconfig..."
      sudo apt update && sudo apt install -y fontconfig
    fi

    # Refresh the font cache
    fc-cache -f -v

    echo "Font cache updated on Ubuntu."

  else
    echo "Unsupported operating system. This script supports macOS and Ubuntu only."
    exit 1
  fi
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
if ! grep -q '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' "$HOME/.zshrc"; then
  echo "Adding Powerlevel10k config source to .zshrc..."
  echo '' >> "$HOME/.zshrc"
  echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> "$HOME/.zshrc"
  echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"
else
  echo "Powerlevel10k config is already sourced in .zshrc."
fi

echo "Setup completed!"
