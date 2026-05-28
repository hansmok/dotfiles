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
    # Core packages, compilers for tree-sitter, and tools
    brew install neovim kitty zsh starship gcc git curl unzip ripgrep fd fd-find
    
elif [ "$OS" == "Linux" ]; then
    case "$DISTRO" in
        ubuntu|debian|pop|mint)
            echo "🔄 Updating apt package lists..."
            sudo apt-get update -y
            
            echo "⚙️ Installing core dependencies via apt..."
            # build-essential provides gcc/g++ required by treesitter compilation
            sudo apt-get install -y neovim kitty zsh git curl unzip ripgrep fd-find build-essential
            ;;
            
        arch|manjaro)
            echo "🔄 Updating pacman package lists..."
            sudo pacman -Syu --noconfirm
            
            echo "⚙️ Installing core dependencies via pacman..."
            # base-devel provides compilers for treesitter
            sudo pacman -S --noconfirm neovim kitty zsh starship git curl unzip ripgrep fd base-devel
            ;;
            
        fedora|rhel|centos)
            echo "🔄 Updating dnf package lists..."
            sudo dnf check-update || true
            
            echo "⚙️ Installing core dependencies via dnf..."
            # Development Tools provides gcc/g++ compilers for treesitter
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y neovim kitty zsh git curl unzip ripgrep fd-find
            ;;
            
        *)
            echo "❌ Linux distribution '$DISTRO' is not explicitly supported by this script."
            echo "Please install neovim, kitty, zsh, starship, ripgrep, fd, and a C-compiler manually."
            exit 1
            ;;
    esac

    # Linux standalone installation hook for Starship (since Debian/Ubuntu/Fedora apt repositories lag behind)
    if ! command -v starship &> /dev/null; then
        echo "⭐ Installing Starship prompt standalone..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# ---------------------------------------------------------------------
# 3. Post-Install Configurations & Health Checks
# ---------------------------------------------------------------------
echo "✅ Essential packages installed successfully."

# Ensure standard utilities like fd map correctly regardless of distro naming conventions
if [ "$OS" == "Linux" ] && [ ! -x "$(command -v fd)" ] && [ -x "$(command -v fdfind)" ]; then
    echo "🔗 Creating symlink alias for fd-find..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

# Automatically change default system shell to Zsh if it isn't already
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🐚 Changing your default shell to Zsh (requires password evaluation)..."
    ZSH_PATH=$(which zsh)
    # Check if zsh path is listed in valid shells file, add if missing on Linux
    if [ "$OS" == "Linux" ] && ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
fi

echo "🎉 Setup complete! Restart your terminal or system to load into your unified environment."
