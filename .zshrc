OS=$(uname)
if [[ $OS == "Darwin" ]]; then
    export PATH=/opt/homebrew/opt/:$PATH
    export PATH=/opt/homebrew/bin/:$PATH
    export PATH=/opt/homebrew/opt/libpq/bin:$PATH
fi
export PATH=~/.local/bin/:$PATH
export PATH=~/.opt/bin:$PATH

setopt correct              # Auto correct mistakes
setopt extendedglob         # Extended globbing. Allows using regular expressions with *
setopt nocaseglob           # Case insensitive globbing
setopt rcexpandparam        # Array expension with parameters
setopt nocheckjobs          # Don't warn about running processes when exiting
setopt numericglobsort      # Sort filenames numerically when it makes sense
setopt nobeep               # No beep
setopt autocd               # if only directory path is entered, cd there.

setopt histignorealldups    # If a new command is a duplicate, remove the older one
setopt appendhistory        # Immediately append history instead of overwriting
setopt inc_append_history   # commands are added to the history immediately
setopt histignorespace      # Don't save commands that start with space
setopt extended_history
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

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

# Don't consider certain characters part of the word
WORDCHARS=${WORDCHARS//\/[&.;]}

function git_branch() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git diff --quiet 2>/dev/null
        if [ $? -ne 0 ]; then
            branch=" %F{#C61F1F}$branch%f"
        else
            branch=" %F{#9BC78D}$branch%f"
        fi
    fi
    print -n $branch
}

function terminal_title() {
    local title=$1
    if [ -n "$SSH_CONNECTION" ]; then
        # This shell is running in an SSH session
        title="$(whoami)@$(hostname) $title"
    fi
    echo -ne "\033]0;$title\007"
}

function zsh_title() {
    # replace home directory with ~
    local dir="${PWD/#$HOME/~}"
    terminal_title "zsh $dir"
}

autoload -Uz add-zsh-hook
# before prompt is displayed
# add-zsh-hook precmd git_branch
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
export LESS="-R -c"
export PAGER=less

if [[ $OS == "Darwin" ]]; then
    eval "$(gdircolors -b)"
    alias ls='gls --color=always' # for mac
else
    eval "$(dircolors -b)"
    alias ls='ls --color=always'
fi

alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color=always -i'
alias rg='rg --color=always -i'
alias free='free -h'
alias df='df -h'
alias cp='cp -i'
alias h='hostname'
alias u='whoami'

alias gs='git status'
alias ga='git add -A'
alias gc='git commit -a'
alias gl='git log'
alias gd='git diff'
alias gr='git remote -v'
alias gb='git --no-pager branch -a'
alias gt='git --no-pager tag'
alias gco='git checkout'

alias d='docker'
alias k='kubectl'

if command -v nvim >/dev/null 2>&1; then
    alias vim=nvim
    export VISUAL="nvim"
else
    export VISUAL="vim"
fi

export TERM="xterm-256color"
export EDITOR="vi -e"

setopt prompt_subst # so git_branch is evaluated
PROMPT='%F{#8caed4}%1~%f$(git_branch) ' # single quotes dealy calling git_branch
if [ -n "$SSH_CONNECTION" ]; then
    PROMPT="%m $PROMPT"
fi

# required by torch.use_deterministic_algorithms(True)
# export CUBLAS_WORKSPACE_CONFIG=:4096:8
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# initialize mamba, this is much faster
if command -v mamba >/dev/null 2>&1; then
    export PATH=$HOME/.opt/miniforge3/bin:$PATH
    source $HOME/.opt/miniforge3/etc/profile.d/conda.sh
    eval "$(mamba shell hook --shell zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
    if output=$(fzf --zsh 2>/dev/null); then
        source <(echo "$output")
    fi
fi
