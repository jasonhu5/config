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
set --universal tide_left_prompt_items status context pwd git python
set -U tide_right_prompt_items
set -U tide_pwd_truncate_margin 1000000000

# add to PATH ~/.local/bin
set PATH ~/.local/bin $PATH

# # aliases
alias sp="source ~/.config/fish/config.fish"
alias b="cd .."
alias c="clear"
# make dir with date or time
alias mkdir-date="mkdir (date +'%Y-%m-%d')"
alias mkdir-time="mkdir (date +'%H_%M_%S')"
alias mkdir-comb-date-time="mkdir (date +'%Y-%m-%d-%H_%M_%S')"
# git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# code search utils
function cgrep -d "search text in folder"
  set -l options 'a/all'  # allow non git directories to be searched
  argparse $options -- $argv

  if not test $_flag_a  # then check if current dir is a git repo
    if git rev-parse --show-toplevel > /dev/null 2>&1
    else
      echo "cgrep: [Warn] Not in a git repository, search not initiated." >&2
      return
    end
  else
    echo "cgrep: File - Line - Match (if any)" >&2
    set _option_allow_non_git "--no-index"
  end

  set _cgrep_res $( \
    git grep --line-number -I $_option_allow_non_git '' | fzf \
    --delimiter ':' \
    --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
    --preview-window down,70%,~3,+{2}+3-/2 \
    --border=sharp --layout=reverse)

  set _cgrep_f $(echo $_cgrep_res | cut -d':' -f1)
  set _cgrep_lineno $(echo $_cgrep_res | cut -d':' -f2)
  set _cgrep_code $(echo $_cgrep_res | cut -d':' -f3-)

  echo $_cgrep_f
  echo $_cgrep_lineno
  echo $_cgrep_code
end

function vgrep -d "search text in folder and open with vim"
  set -l options 'a/all'  # allow non git directories to be searched
  argparse $options -- $argv

  if test $_flag_a
    set _option_allow_non_git "-a"
  end
  set cgrep_res $(cgrep $_option_allow_non_git)
  # the `cgrep` stdout result is an array[3]
  # [1]: file name
  # [2]: line number
  # [3]: (might be blank) matched file content

  if not test -f "$cgrep_res[1]"
    echo "vgrep: [Warn] No valid file provided. No action performed."
    return
  end

  # open file, navigate to line, highlight line
  command vim +"$cgrep_res[2]" +'set cursorline' "$cgrep_res[1]"

  for i in (seq 1 3)
    echo "$cgrep_res[$i]"
  end
end
