setopt correct              # Auto correct mistakes
setopt extendedglob         # Extended globbing. Allows using regular expressions with *
setopt nocaseglob           # Case insensitive globbing
setopt rcexpandparam        # Array expension with parameters
setopt nocheckjobs          # Don't warn about running processes when exiting
setopt numericglobsort      # Sort filenames numerically when it makes sense
setopt nobeep               # No beep
setopt appendhistory        # Immediately append history instead of overwriting
setopt histignorealldups    # If a new command is a duplicate, remove the older one
setopt autocd               # if only directory path is entered, cd there.
setopt inc_append_history   # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace      # Don't save commands that start with space
setopt share_history

bindkey -e

# Case insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# automatically find new executables in path 
zstyle ':completion:*' rehash true
# Highlight menu selection
zstyle ':completion:*' menu select
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
# Don't consider certain characters part of the word
WORDCHARS=${WORDCHARS//\/[&.;]}

function git_branch () {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git diff --quiet 2>/dev/null
        if [ $? -ne 0 ]; then
            branch="*"$branch
        fi
        branch=" $branch"
    fi
    psvar[1]=$branch
}

function terminal_title() {
    echo -ne "\033]0;$1\007"
}

function zsh_title() {
    # replace home directory with ~
    local dir="${PWD/#$HOME/~}"
    terminal_title "zsh $dir"
}

autoload -Uz add-zsh-hook
# before prompt is displayed
add-zsh-hook precmd git_branch
add-zsh-hook precmd zsh_title
# before command is executed
add-zsh-hook preexec terminal_title

function tmux_win_name_cmd() {
    cmd=${1##*|}
    cmd=${cmd## }
    cmd=${cmd#sudo *}
    cmd=${cmd%% *}
    tmux rename-window -t $TMUX_PANE $cmd
}

function tmux_win_name_reset() {
    tmux rename-window -t $TMUX_PANE "zsh"
}

if [[ -n $TMUX_PANE ]]; then
    export TMUX_WIN_NAME=$(tmux display-message -p '#W')
    add-zsh-hook precmd tmux_win_name_reset
    add-zsh-hook preexec tmux_win_name_cmd
    trap 'tmux rename-window -t $TMUX_PANE $TMUX_WIN_NAME' EXIT
fi


# theming
autoload -U compinit colors zcalc
compinit -d
colors

# less colours (including man pages)
export LESS_TERMCAP_mb=$'\e[38;5;186m'          # begin bold
export LESS_TERMCAP_md=$'\e[38;5;104m'          # begin bold
export LESS_TERMCAP_me=$'\e[0m'                 # reset bold
export LESS_TERMCAP_so=$'\e[38;5;222;48;5;235m' # begin standout
export LESS_TERMCAP_se=$'\e[0m'                 # reset standout
export LESS_TERMCAP_us=$'\e[38;5;217m'          # begin underline
export LESS_TERMCAP_ue=$'\e[0m'                 # reset underline
export GROFF_NO_SGR=1
export LESS="-R"
export PAGER=less

eval "$(dircolors -b)"

alias ls='ls --color=always'
alias ll='ls -l'
alias grep='grep --color=always'
alias free='free -m'
alias df='df -h'
alias cp='cp -i'
alias vim=nvim

alias gs='git status'
alias ga='git add -A'
alias gc='git commit -a'
alias gl='git log'
alias gd='git diff'
alias gr='git remote -v'
alias gb='git --no-pager branch -a'
alias gt='git --no-pager tag'

alias k='kubectl'

export TERM="xterm-256color"
export EDITOR="vi -e"
export VISUAL="nvim"
export PATH=~/.opt/bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/m/.opt/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/m/.opt/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/m/.opt/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/m/.opt/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/m/.opt/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/home/m/.opt/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

# set prompt after conda init so conda env name is not shown for base env
PS1="%F{#34DCF7}%1~%f%F{#9BC78D}%v%f "

# required by torch.use_deterministic_algorithms(True)
export CUBLAS_WORKSPACE_CONFIG=:4096:8

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

