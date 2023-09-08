export VIRTUAL_ENV_DISABLE_PROMPT=1

_PROMPT_PREFIX_='%B❯%b'
_PROMPT_STATUS_='%(?:%{$fg_bold[green]%}$_PROMPT_PREFIX_:%{$fg_bold[red]%}$_PROMPT_PREFIX_)'
_VIRTUALENV_INFO_='$(virtualenv_info)'

ZSH_THEME_K8S_PREFIX="%B$FG[051]%}k8s:(%{$FG[219]%}"
ZSH_THEME_K8S_SUFFIX="%B$FG[051]%})%{$reset_color%}"

ZSH_THEME_AWS_PREFIX="%B$FG[226]%}aws:(%{$FG[194]%}"
ZSH_THEME_AWS_SUFFIX="%B$FG[226]%})%{$reset_color%}"

# ZSH_THEME_TIME_PREFIX="%B$FG[039]%}[%{$FG[159]%}"
# ZSH_THEME_TIME_SUFFIX="%B$FG[039]%}]%{$reset_color%}"

ZSH_THEME_TIME_PREFIX="%B$FG[076]%}"
ZSH_THEME_TIME_SUFFIX="%{$reset_color%}"

ZSH_THEME_VIRTUALENV_PREFIX="%{$FG[116]%}("
ZSH_THEME_VIRTUALENV_SUFFIX=") %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$fg[blue]%})"

function postcmd_newline() {
  # add a newline after every prompt except the first line 
  precmd() {
    precmd() {
      print "" 
    }
  } 
}

function get_current_dir() {
  echo "%{$fg[cyan]%}%c%{$reset_color%}"
}

function virtualenv_info() {
  [[ -n ${VIRTUAL_ENV} ]] || return
  echo "${ZSH_THEME_VIRTUALENV_PREFIX}${VIRTUAL_ENV:t:gs/%/%%}${ZSH_THEME_VIRTUALENV_SUFFIX}"
}

function aws_profile() {
  [[ -n ${AWS_PROFILE} ]] || return
  echo "${ZSH_THEME_AWS_PREFIX}$AWS_PROFILE${ZSH_THEME_AWS_SUFFIX}"
}

# function get_current_time() {
#   echo "$(matte_grey '%D{%d/%m %T}') $(get_seperator)"
# }

# function get_current_time() {
#   echo "${ZSH_THEME_TIME_PREFIX}%D{%d/%m %T}${ZSH_THEME_TIME_SUFFIX}"
# }

function get_current_time() {
  echo "${ZSH_THEME_TIME_PREFIX}%D{%T}${ZSH_THEME_TIME_SUFFIX}"
}

function get_cluster() {
  local current_context=$(kubectl config current-context)
  if [[ -n $current_context ]] || return
  if [[ $current_context == *":eks:"* ]]; then
    local cluster=eks/${current_context#*cluster/}
  else
    local cluster=$current_context
  fi
  echo "${ZSH_THEME_K8S_PREFIX}$cluster${ZSH_THEME_K8S_SUFFIX} $(get_seperator)"
}

function get_seperator() {
  echo "$(matte_grey —)"
}

function top_right_corner() {
  echo "$(get_seperator)$(matte_grey ╮)"
}

function get_space() {
  local size=$1
  local space=$(get_seperator)
  while [[ $size -gt 0 ]]; do
    space="$space$(get_seperator)"
    let size=$size-1
  done
  echo "$space"
}

function matte_grey() {
  echo "%{$FG[240]%}$1%{$reset_color%}"
}

function prompt_len() {
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  echo $x
}

function prompt_header() {
  local left_prompt="$(get_current_dir) $(git_prompt_info)$(get_current_time) "
  local right_prompt=" $(get_cluster) $(aws_profile)"
  local prompt_len=$(prompt_len $left_prompt$right_prompt)
  local space_size=$(( $COLUMNS - $prompt_len - 1 ))
  local space=$(get_space $space_size)

  print -rP "$left_prompt$space$right_prompt"
}

postcmd_newline
alias clear="clear; postcmd_newline"

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_header
setopt prompt_subst
ZLE_RPROMPT_INDENT=0

PROMPT="$_VIRTUALENV_INFO_$_PROMPT_STATUS_ "

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_header
