# prevent duplicate paths in OS X
if [[ -x /usr/libexec/path_helper ]]; then
    eval `/usr/libexec/path_helper -s`
fi

# any private directives go here
[[ -r ~/.bash_privates ]] && source ~/.bash_privates

export PATH="$PATH:/usr/local/opt/ruby/bin"

# reset prompt command in subshells
if [[ $SHLVL > 1 ]]; then
    unset PROMPT_COMMAND
fi

# OS X-specific
if [[ $(uname -s) == 'Darwin' ]]; then
    alias ls='ls -G'
fi

# Linux-specific
if [[ $(uname -s) == 'Linux' ]]; then
    : # pass
fi

# set terminal prompt
# original powerline
export powerline="$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")/powerline"
export powerline_bash="${powerline}/bindings/bash/powerline.sh"
export powerline_tmux="${powerline}/bindings/tmux/powerline.conf"
export powerline_vim="${powerline}/bindings/vim"
# powerline-shell fork
export powerline_shell="$HOME/.powerline-shell.py"

# terminal prompt
if [[ -r $powerline_bash ]]; then
    source "$powerline_bash"
elif [[ -x $powerline_shell ]]; then
    function _update_ps1() {
       export PS1="$("$powerline_shell" --cwd-max-depth 4 --colorize-hostname --mode flat $? 2> /dev/null)"
    }
    export PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
elif [[ -f "$HOME/.bash_ps1" ]]; then
    source "$HOME/.bash_ps1"
else
    export PS1="\u@\h: \w$ "
fi

# aliases
alias ll='ls -lh'
alias la='ls -lha'
alias cd='pushd 1>/dev/null'

# enable color support for ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# bash options
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob

# unified bash history
set +o histexpand
shopt -s histappend
HISTSIZE=2500
HISTFILESIZE=2500

history(){
  __sync_history
  builtin history "$@"
}

__sync_history() {
  builtin history -a
  HISTFILESIZE=$HISTFILESIZE
  builtin history -c
  builtin history -r
}

export PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | sed -e 's/[;[[:blank:]]]*$//')
#export PROMPT_COMMAND="$([[ $PROMPT_COMMAND ]] && echo "${PROMPT_COMMAND}; ")__sync_history"
export PROMPT_COMMAND="$PROMPT_COMMAND"$'\n__sync_history'

# install cronjobs
(crontab -l | sed -e '/^# begin dotfile jobs$/,/^# end dotfile jobs$/d'; cat $HOME/.cron) | crontab -

# homebrew installation prefix if present
prefix=$(brew --prefix 2>/dev/null || true) # won't break -e
    
# bash completion
bash_completion="${prefix}/etc/bash_completion"
if [[ -f $bash_completion ]]; then
    source "$bash_completion"
fi

# z
z="${prefix}/etc/profile.d/z.sh"
if [[ -f $z ]]; then
    source "$z"
fi

# virtualenvwrapper
export WORKON_HOME="$HOME/.virtualenvs"
export PROJECT_HOME="$HOME/devel"

# pyenv
if which pyenv &> /dev/null; then
    export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
    eval "$(pyenv init -)"
    pyenvroot=$(pyenv root)
    if [[ -d ${pyenvroot}/plugins/pyenv-autoenv ]]; then
        source "${pyenvroot}/plugins/pyenv-autoenv/bin/pyenv-autoenv"
    fi
    if [[ -d ${pyenvroot}/plugins/pyenv-virtualenvwrapper ]]; then
        pyenv virtualenvwrapper_lazy
    fi
fi

# rbenv
if which rbenv > /dev/null; then 
    export RBENV_ROOT="$HOME/.rbenv"
    eval "$(rbenv init -)"
fi
