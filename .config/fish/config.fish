# suppress greetings
set fish_greeting

# default editor
set -gx EDITOR vim

# bind Ctrl+h to accept the default suggestion
bind \ch forward-char

# make fzf search hidden files too
set -U fzf_fd_opts --hidden --no-ignore --exclude .git
fzf_configure_bindings --git_status=\cs --git_log=\cl --directory=\cf --processes=\cp

# set tide prompts
set --universal tide_left_prompt_items status context pwd git virtual_env
set -U tide_right_prompt_items
set -U tide_pwd_truncate_margin 1000000000

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
alias gb="git branch"
