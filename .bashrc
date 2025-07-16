#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Shortcut for refreshing .bashrc
alias resource='source ~/.bashrc'

# Add alias for dotfiles bare repo
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# For restarting kanata daemon
alias restart='sudo systemctl restart kanata'

# Open my todo list
alias todo='nvim ~/todo.txt'

# Switch to my cube project
alias cube='cd /mnt/shared/projects/new_cube_sim'
alias cubed='cd /mnt/shared/projects/new_cube_sim/bin/debug'

# Command to make project outside of nvim 
alias makep='cmake -G Ninja -S . -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug && cmake --build build --config Debug'

PS1='[\u@\h \W]\$ '

# Add scripts to path
export PATH="$HOME/scripts:$PATH"

export TERMINAL=alacritty
