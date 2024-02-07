# Path to your oh-my-zsh installation.
#export ZSH="/Users/zcheng/.oh-my-zsh"


ZSH_THEME="robbyrussell"


plugins=(git vi-mode)

# doom emacs
export PATH="$PATH:$HOME/.emacs.d/bin" 

# term
export TERM=xterm-256color
alias ssh="TERM=xterm-256color ssh"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# direnv setup
eval "$(direnv hook zsh)"

alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox'
alias safari='open -a Safari'

# shell prompt
# case $TERM in
#     xterm*)
#         precmd () {print -Pn "\e]0;%n@%m: %~\a"}
#         ;;
# esac

bindkey '^f' autosuggest-accept

# who is using the port
whoport() {
  lsof -nP -i4TCP:"$1" | grep LISTEN
}

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# ihp editor
# export IHP_EDITOR="code --goto"
# export IHP_BROWSER=chrome
# export IHP_TELEMETRY_DISABLED=1



# private stuff
source ~/.private.zshrc 2> /dev/null
