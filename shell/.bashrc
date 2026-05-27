#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.npm-global/bin:$PATH"

export PATH="$HOME/.pyenv/bin:$PATH"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

alias ls='ls --color=auto'
PS1='\u@\h \W λ '
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/"
