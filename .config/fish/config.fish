# suppress greetings
set fish_greeting

# default editor
set -gx EDITOR vim

# bind Ctrl+h to accept the default suggestion
bind \ch forward-char

# make fzf search hidden files too
set -U fzf_fd_opts --hidden --exclude .git

# set tide prompts
set -g tide_left_prompt_items status newline context pwd git virtual_env
set -g tide_right_prompt_items
set -g tide_pwd_truncate_margin 1000000000

# add to PATH ~/.local/bin
set PATH ~/.local/bin $PATH

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

# bolt config
set -U BOLT_DISABLE_ANALYTICS true


