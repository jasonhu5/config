# suppress greetings
set fish_greeting

# default editor
set -gx EDITOR vim

# bind Ctrl+h to accept the default suggestion
bind \ch forward-char

# make fzf search hidden files too
set -U fzf_fd_opts --hidden --exclude .git

# aliases
alias sp="source ~/.config/fish/config.fish"
alias b="cd .."
alias c="clear"

# git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git pull"
alias gd="git diff"
