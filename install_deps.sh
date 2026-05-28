#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting dotfiles dependency installer..."

# ---------------------------------------------------------------------
# 1. OS & Package Manager Detection
# ---------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    if ! command -v brew &> /dev/null; then
        echo "🍺 Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to path for the current execution session
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
else
    echo "❌ Unsupported OS type: $OSTYPE"
    exit 1
fi

echo "📦 Detected System: $OS ($DISTRO)"

# ---------------------------------------------------------------------
# 2. Dependency Installation Routing
# ---------------------------------------------------------------------
if [ "$OS" == "macOS" ]; then
    echo "🔄 Updating Homebrew..."
    brew update

    echo "⚙️ Installing core dependencies via Homebrew..."
    brew install neovim kitty zsh starship gcc git curl unzip ripgrep fd fd-find stow
    
elif [ "$OS" == "Linux" ]; then
    case "$DISTRO" in
        ubuntu|debian|pop|mint)
            echo "🔄 Updating apt package lists..."
            sudo apt-get update -y
            
            echo "⚙️ Installing core dependencies via apt..."
            sudo apt-get install -y neovim kitty zsh git curl unzip ripgrep fd-find build-essential stow
            ;;
            
        arch|manjaro)
            echo "🔄 Updating pacman package lists..."
            sudo pacman -Syu --noconfirm
            
            echo "⚙️ Installing core dependencies via pacman..."
            sudo pacman -S --noconfirm neovim kitty zsh starship git curl unzip ripgrep fd base-devel stow
            ;;
            
        fedora|rhel|centos)
            echo "🔄 Updating dnf package lists..."
            sudo dnf check-update || true
            
            echo "⚙️ Installing core dependencies via dnf..."
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y neovim kitty zsh git curl unzip ripgrep fd-find stow
            ;;
            
        *)
            echo "❌ Linux distribution '$DISTRO' is not explicitly supported by this script."
            echo "Please install dependencies manually."
            exit 1
            ;;
    esac

    # Linux standalone installation hook for Starship (if distro repositories lag behind)
    if ! command -v starship &> /dev/null; then
        echo "⭐ Installing Starship prompt standalone..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# Ensure standard utilities like fd map correctly regardless of distro naming conventions
if [ "$OS" == "Linux" ] && [ ! -x "$(command -v fd)" ] && [ -x "$(command -v fdfind)" ]; then
    echo "🔗 Creating symlink alias for fd-find..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

# ---------------------------------------------------------------------
# 3. AUTOMATED CONFIG MAPPING (Stow Sequence)
# ---------------------------------------------------------------------
echo "📦 Mapping configuration files with GNU Stow..."

# Ensure core target directories exist before linking
mkdir -p "$HOME/.config"

# Navigate into the dotfiles directory so the relative paths match perfectly
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# 1. Map kitty and starship (They already contain .config/ inside them)
stow kitty
stow starship

# 2. Map your shell files (.zshrc and .bashrc directly to your home folder)
stow shell

# 3. Map nvim (Explicitly target ~/.config/nvim since init.lua sits at its root)
mkdir -p "$HOME/.config/nvim"
stow -t "$HOME/.config/nvim" nvim

echo "✨ Configuration symlinks successfully created!"

# ---------------------------------------------------------------------
# 4. Post-Install Shell Adjustments
# ---------------------------------------------------------------------
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🐚 Changing your default shell to Zsh (requires password evaluation)..."
    ZSH_PATH=$(which zsh)
    if [ "$OS" == "Linux" ] && ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
fi

echo "🎉 Setup complete! All packages are installed and your configuration links are fully active."
