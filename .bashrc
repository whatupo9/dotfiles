#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias resource='source ~/.bashrc'

# Aliases for switching keyboard remappings
alias typing='sudo systemctl stop kanata.service && sudo systemctl start typing.service'
alias restart='sudo systemctl stop typing.service && sudo systemctl start kanata.service'

# Add alias for dotfiles bare repo
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'


PS1='[\u@\h \W]\$ '
