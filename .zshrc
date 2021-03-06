# zsh config
# -----------------------------------------
export ZSH=/Users/giancarloanemone/.oh-my-zsh
export UPDATE_ZSH_DAYS=13
export FZF_BASE=/usr/local/bin/fzf
ZSH_THEME="amuse"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(
  fancy-ctrl-z
  fzf
  autojump 
  last-working-dir 
  vi-mode 
  history-substring-search 
  zsh-completions 
  git-extras 
  cp
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
export PATH=$HOME/.cargo/bin:$PATH
# code() {
#   "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" $@
# }
[[ -s $BREW_PREFIX/etc/profile.d/autojump.sh ]] && . $BREW_PREFIX/etc/profile.d/autojump.sh
# -----------------------------------------

## Personal Config
# -----------------------------------------
export EDITOR='nvim'
export PORT_HTTP=3000
# -----------------------------------------

source $ZSH/oh-my-zsh.sh

# Splitting up bashrc files
BASH_PATH=$HOME/dev/bash
source $BASH_PATH/secrets.sh
source $BASH_PATH/aliases.sh
source $BASH_PATH/phab.sh
source $BASH_PATH/internal.sh
