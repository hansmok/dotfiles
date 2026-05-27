# ~/.zshrc
# If not running interactively, don't do anything 
[[ ! -o interactive ]] && return


# --- Pyenv Initialization ---
export PATH="$HOME/.pyenv/bin:$PATH" 
eval "$(pyenv init -)" 
eval "$(pyenv virtualenv-init -)" 

# --- Aliases ---
alias ls='ls --color=auto' 

# Set where the history file is stored
HISTFILE=~/.zsh_history

# Number of lines to keep in the current session's memory
HISTSIZE=10000

# Number of lines to save in the history file on disk
SAVEHIST=10000

# (Optional) Share history between all open terminal windows
setopt SHARE_HISTORY

# (Optional) Append to history immediately (don't wait for shell to exit)
setopt INC_APPEND_HISTORY


# --- Custom Aliases ---
alias v='nvim'
alias g='git'
alias gs='git status'
alias dotfiles='cd ~/dotfiles'
alias pacup='sudo pacman -Syu' # Quick Arch system update

# --- Zsh Custom Prompt (Lambda) ---
# PROMPT='%n@%m %1~ λ '
eval "$(starship init zsh)"
