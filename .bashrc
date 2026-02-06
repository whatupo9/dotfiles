#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR=nvim

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Shortcut for refreshing .bashrc
alias resource='source ~/.bashrc'

# Add alias for dotfiles bare repo
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# For restarting kanata daemon
alias restart='sudo systemctl restart kanata'

# Open my todo list
alias todolist='nvim ~/todo.txt'

# Switch to my projects
alias cube='cd /mnt/shared/projects/new_cube_sim'
alias cubed='cd /mnt/shared/projects/new_cube_sim/bin/debug'
alias opengl='cd /mnt/shared/projects/learnopengl'
alias opengld='cd /mnt/shared/projects/learnopengl/bin/debug'

alias saidIt='~/projects/aidanCounter/aidan'
alias equations='feh ~/Pictures/Screenshots/2025-09-16_17-11-03.png -Z -F'

# Count the lines of code in a project
alias loc='find src include -type f -exec cat {} + | wc -l'

# Command to make project outside of nvim 
alias makep='cmake -G Ninja -S . -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug && cmake --build build --config Debug'

alias feh='feh -Z'

PS1='[\u@\h \W]\$ '

# Add scrip folder to path
export PATH="$HOME/.local/bin:$PATH"

# Add todo to path
export PATH="/mnt/shared/projects/todo/bin/debug:$PATH"

export TERMINAL=alacritty
