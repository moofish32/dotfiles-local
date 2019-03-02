# setup
autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
setopt prompt_subst

# prompt
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$reset_color%}%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$reset_color%}%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[yellow]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"

# show git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
}

# show yellow x if there are uncommitted changes
parse_git_dirty() {
  if command git diff-index --quiet HEAD 2> /dev/null; then
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  else
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  fi
}

# if in a git repo, show dirty indicator + git branch
git_custom_status() {
  local git_where="$(parse_git_branch)"
  # [ -n "$git_where" ] && echo "$ZSH_THEME_GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$ZSH_THEME_GIT_PROMPT_SUFFIX$(parse_git_dirty)"
  [ -n "$git_where" ] && echo "$(parse_git_dirty)[${git_where#(refs/heads/|tags/)}] ✗"
}

# show current rbenv version if different from rbenv global
rbenv_version_status() {
  if which rbenv &> /dev/null; then
    local ver=$(rbenv version-name)
    [ "$(rbenv global)" != "$ver" ] && echo "[$ver]"
  else
    echo ""
  fi
}

aws_settings() {
  if [[ -n $AWS_DEFAULT_PROFILE ]]; then
    echo "[$AWS_DEFAULT_PROFILE@$AWS_DEFAULT_REGION]"
  else
    echo ""
  fi
}

# Right hand prompt
RPS1='%{$fg[red]%}$(rbenv_version_status)%{$fg[yellow]%}$(aws_settings)%{$reset_color%} $EPS1'


# basic prompt on the left
PROMPT='%{$fg[cyan]%}%~% %(?.%{$fg[green]%}.%{$fg[red]%})$(git_custom_status)%B%b '
