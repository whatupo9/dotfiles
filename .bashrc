#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR=nvim

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias off='shutdown now'

alias night='redshift -O 1500 && brightnessctl set 1 > /dev/null 2>&1'
alias day='redshift -x && brightnessctl set 15% > /dev/null 2>&1'

alias watts="watch -n 1 'upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E \"energy-rate|percentage\"'"

# Shortcut for refreshing .bashrc
alias resource='source ~/.bashrc'

# Add alias for dotfiles bare repo
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Count the lines of code in a project
alias loc='find src include -type f -exec cat {} + | wc -l'

alias feh='feh -Z'

# Copy contents of a file to clipboard
copy() {
    cat "$@" | xclip -selection clipboard
}

# Configure Terminal Prompt
COLOR_RED="\[\e[1;31m\]"
COLOR_YELLOW="\[\e[38;5;185m\]"
COLOR_PURPLE="\[\e[38;5;133m\]"
COLOR_BLUE="\[\e[38;5;38m\]"
COLOR_RESET="\[\e[0m\]"

alias simple="SIMPLE=1"
alias nosimple="SIMPLE=0"

update_prompt() {
  # Write a simple prompt if flag is set
  if [[ "$SIMPLE" == "1" ]]; then
      PS1="❱ "
      return
  fi

  # Choose color based on user
  if [ "$(id -un)" = "root" ]; then
      USER_COLOR=$COLOR_RED
      ARROW_COLOR=$COLOR_RED
  elif [[ "$(id -un)" = "cam" || "$(id -un)" == "clmacgil" ]]; then
      USER_COLOR=$COLOR_BLUE
      ARROW_COLOR=$COLOR_RESET
  else
      USER_COLOR=$COLOR_YELLOW
      ARROW_COLOR=$COLOR_RESET
  fi

  # Choose color based on hostname
  if [ "$HOSTNAME" = "homelab" ]; then
      HOST_COLOR=$COLOR_RED
  elif [ "$HOSTNAME" = "anvil" ]; then
      HOST_COLOR=$COLOR_BLUE
  else
      HOST_COLOR=$COLOR_YELLOW
  fi

  if [[ "$PWD" == "$HOME" || "$PWD" == "$HOME"/* ]]; then
      PATH_COLOR=$COLOR_PURPLE
  else
      PATH_COLOR=$COLOR_RED
  fi

  PS1="${USER_COLOR}\u${COLOR_RESET}@${HOST_COLOR}\h ${PATH_COLOR}\w${ARROW_COLOR}\n❱${COLOR_RESET} "
}

PROMPT_COMMAND=update_prompt


# Add binary folder to path
export PATH="$HOME/.local/bin:$PATH"

# Add script folder to path
export PATH="$HOME/scripts:$PATH"

export TERMINAL=alacritty

export TZ=America/Toronto

[ -f ~/.bashrc.local ] && source ~/.bashrc.local
export PATH="$HOME/.elan/bin:$PATH"
