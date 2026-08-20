# Path to your oh-my-zsh installation.
#export ZSH="/Users/zcheng/.oh-my-zsh"


ZSH_THEME="robbyrussell"


plugins=(git vi-mode)

# doom emacs
export PATH="$PATH:$HOME/.emacs.d/bin" 
# go tools
export PATH="$PATH:$HOME/go/bin"

# linux
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.config/agency/CurrentVersion"

# term
export TERM=xterm-256color
alias ssh="TERM=xterm-256color ssh"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# fix tmux a -t <session> for remote ssh 
 export TERMINFO_DIRS=/usr/share/terminfo

# direnv setup
eval "$(direnv hook zsh)"

# fnm setup
eval "$(fnm env --use-on-cd)"

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



# --- GNOME Keyring (WSL) ----------------------------------------------------
# Secure, persistent secret storage via the Secret Service API (org.freedesktop.secrets).
# Starts a single daemon per session (reused by later shells) and unlocks the
# password-protected "login" keyring. On the very first run, the password you
# type becomes the keyring password; it is created encrypted at
# ~/.local/share/keyrings/login.keyring.
if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  # Ensure the user D-Bus session bus is running (WSL doesn't start it on login).
  if [ ! -S "$XDG_RUNTIME_DIR/bus" ]; then
    systemctl --user start dbus.socket 2>/dev/null
  fi
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

  keyring-unlock() {
    if pgrep -u "$USER" -f gnome-keyring-daemon >/dev/null 2>&1; then
      echo "gnome-keyring is already running." >&2
      return 0
    fi
    local _kr_pw
    printf 'Unlock GNOME keyring: '
    read -rs _kr_pw; printf '\n'
    # PAM-style two-phase init: unlock the login keyring, then register services.
    printf '%s' "$_kr_pw" | gnome-keyring-daemon --daemonize --login --components=secrets >/dev/null 2>&1
    gnome-keyring-daemon --start --components=secrets >/dev/null 2>&1
    unset _kr_pw
  }

  # Auto-unlock once per session, only in an interactive terminal.
  if [[ -o interactive ]] && [ -t 0 ] \
     && ! pgrep -u "$USER" -f gnome-keyring-daemon >/dev/null 2>&1; then
    keyring-unlock
  fi
fi
# ----------------------------------------------------------------------------

# private stuff
source ~/.private.zshrc 2> /dev/null
