# v1.0.0
# https://github.com/hejmsdz/myzsh

# display user@hostname if connected via SSH
function user() {
  if [[ -n $SSH_CONNECTION ]]
  then
    echo '%F{green}%n@%m%f '
  fi
}

# display current directory or Git info
function directory() {
  local branch=$(current_branch 2> /dev/null)
  if [[ -n $branch ]]; then # inside a repository
    local git_root=$(git rev-parse --show-toplevel)
    local git_root_base=$(basename $git_root)
    if [[ $branch = 'master' ]]; then # abbreviate it
      branch='M'
    fi
    local branch_info="[$branch$(parse_git_dirty)]"
    echo -n "%F{cyan}$git_root_base%f%F{yellow}$branch_info%f"
    if [[ $PWD != $git_root ]]; then
      local relative=$(realpath --relative-to=$git_root $PWD)
      echo -n "%F{blue}/$relative%f"
    fi
  else
    echo "%F{blue}%~%f"
  fi
}

function char() {
  echo ' %(!.%F{red}#%f.$) '
}

function preexec() {
  CMD_START_TIME=$(date +%s.%N)
}

function precmd() {
  local now=$(date +%s.%N)

  if [[ -n $CMD_START_TIME ]]
  then
    ((CMD_TIME=$now-$CMD_START_TIME))
  else
    CMD_TIME=0
  fi
  unset CMD_START_TIME
}

function format_time() {
  local value=$(LC_NUMERIC=C printf "%.2f\n" $1)
  [[ $value -ge 60 ]] && long=1

  local s=$(($value%60))
  ((value=$value/60))
  integer m=$(($value%60))
  ((value=$value/60))
  integer h=$value

  if [[ $h -ge 1 ]]; then
    printf '%dh' $h
  fi
  if [[ $m -ge 1 ]]; then
    printf '%dm' $m
  fi
  if [[ $s -gt 0 && -z $long ]]; then
    printf '%.2fs' $s
  elif [[ $s -ge 1 && -n $long ]]; then
    printf '%ds' $s
  fi
}

function last_status() {
  local code=$?
  if [[ $CMD_TIME -ge $CMD_TIME_THRESHOLD ]]; then
    echo -n " %F{yellow}$(format_time $CMD_TIME)%f"
  fi
  if [[ $code -ne 0 ]]; then
    echo -n " %F{red}exit $code%f"
  fi
}

CMD_TIME_THRESHOLD=0.2

PROMPT='%B$(user)$(directory)$(char)%b'
RPROMPT='$(last_status)'

ZSH_THEME_GIT_PROMPT_DIRTY='*'
ZSH_THEME_GIT_PROMPT_CLEAN=''
