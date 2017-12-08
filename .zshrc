# zsh config
# -----------------------------------------
export ZSH=/Users/giancarloanemone/.oh-my-zsh
export UPDATE_ZSH_DAYS=13
ZSH_THEME="amuse"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(
  autojump 
  last-working-dir 
  vi-mode 
  zsh-syntax-highlighting 
  history-substring-search 
  zsh-completions 
  git-extras 
)
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
# -----------------------------------------


# PATH CONFIG
# -----------------------------------------
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"
BREW_PREFIX=$(brew --prefix)
export PATH=$BREW_PREFIX/sbin:$BREW_PREFIX/bin:$PATH:$HOME/bin
[[ -s $BREW_PREFIX/etc/profile.d/autojump.sh ]] && . $BREW_PREFIX/etc/profile.d/autojump.sh
# -----------------------------------------

## Personal Config
# -----------------------------------------
export EDITOR='nvim'
export NODE_ENV="development"
export PORT_HTTP=3000
# -----------------------------------------

source $ZSH/oh-my-zsh.sh

# Splitting up bashrc files
BASH_PATH=$HOME/dev/bash
source $BASH_PATH/secrets.sh
source $BASH_PATH/npm.sh
source $BASH_PATH/nvm.sh
source $BASH_PATH/aliases.sh
source $BASH_PATH/phab.sh
source $BASH_PATH/internal.sh
