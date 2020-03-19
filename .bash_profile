# Path Setup

# Cargo https://github.com/rust-lang/cargo
PATH="$PATH:$HOME/.cargo/bin"
# Bloop https://scalacenter.github.io/bloop/
PATH="$PATH:$HOME/.bloop"

# Aliases
# Port Checking
port() {
   sudo lsof -Pni :"$1"
}
alias code='cd ~/code'

# Git Prompt https://gist.github.com/michaelneu/943693f46f7aa249fad2e6841cd918d5
COLOR_GIT_CLEAN='\[\033[1;30m\]'
COLOR_GIT_MODIFIED='\[\033[0;33m\]'
COLOR_GIT_STAGED='\[\033[0;36m\]'
COLOR_RESET='\[\033[0m\]'

function git_prompt() {
  if [ -e ".git" ]; then
    branch_name=$(git symbolic-ref -q HEAD)
    branch_name=${branch_name##refs/heads/}
    branch_name=${branch_name:-HEAD}

    echo -n "→ "

    if [[ $(git status 2> /dev/null | tail -n1) = *"nothing to commit"* ]]; then
      echo -n "$COLOR_GIT_CLEAN$branch_name$COLOR_RESET"
    elif [[ $(git status 2> /dev/null | head -n5) = *"Changes to be committed"* ]]; then
      echo -n "$COLOR_GIT_STAGED$branch_name$COLOR_RESET"
    else
      echo -n "$COLOR_GIT_MODIFIED$branch_name*$COLOR_RESET"
    fi

    echo -n " "
  fi
}

function prompt() {
  PS1="\[\033[0;33m\][\A]\[\033[0m\] [ \w $(git_prompt)] \$ "
}

PROMPT_COMMAND=prompt


# Gradle Wrapper Alias
function gw() {
  local dir=$PWD
  while [[ $dir != '/' && ! -x $dir/gradlew ]]
  do
    dir=`dirname $dir`
  done
  if [ ! -x $dir/gradlew ]
  then
    echo "Cannot find gradlew script in this directory or its parents :-(" >&2
    return 1
  fi
  $dir/gradlew "$@"
}

cd ~/code

# exec nvim -v 'terminal'
