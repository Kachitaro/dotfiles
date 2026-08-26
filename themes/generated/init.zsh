# Auto-generated Zsh init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

# --- atuin init ---
export ATUIN_TMUX_POPUP=false
# shellcheck disable=SC2034,SC2153,SC2086,SC2155

# Above line is because shellcheck doesn't support zsh, per
# https://github.com/koalaman/shellcheck/wiki/SC1071, and the ignore: param in
# ludeeus/action-shellcheck only supports _directories_, not _files_. So
# instead, we manually add any error the shellcheck step finds in the file to
# the above line ...

# Source this in your ~/.zshrc
autoload -U add-zsh-hook

zmodload zsh/datetime 2>/dev/null

# If zsh-autosuggestions is installed, configure it to use Atuin's search. If
# you'd like to override this, then add your config after the $(atuin init zsh)
# in your .zshrc
_zsh_autosuggest_strategy_atuin() {
    # silence errors, since we don't want to spam the terminal prompt while typing.
    # '$all-user' is a literal atuin author filter, not a shell variable
    # shellcheck disable=SC2016
    suggestion=$(ATUIN_QUERY="$1" atuin search --cmd-only --author '$all-user' --limit 1 --search-mode prefix 2>/dev/null)
}

if [ -n "${ZSH_AUTOSUGGEST_STRATEGY:-}" ]; then
    ZSH_AUTOSUGGEST_STRATEGY=("atuin" "${ZSH_AUTOSUGGEST_STRATEGY[@]}")
else
    ZSH_AUTOSUGGEST_STRATEGY=("atuin")
fi

if [[ -z "${ATUIN_SESSION:-}" || "${ATUIN_SHLVL:-}" != "$SHLVL" ]]; then
    export ATUIN_SESSION=$(atuin uuid)
    export ATUIN_SHLVL=$SHLVL
fi
ATUIN_HISTORY_ID=""

__atuin_osc133_command_executed() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" ]] || return

    printf '\033]133;C\a'
}

__atuin_osc133_command_finished() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" ]] || return

    printf '\033]133;D;%s;history_id=%s;session_id=%s\a' "$1" "$ATUIN_HISTORY_ID" "${ATUIN_SESSION:-}"
}

__atuin_osc133_prompt_start=$'%{\033]133;A;cl=line\a%}'
__atuin_osc133_prompt_end=$'%{\033]133;B\a%}'

__atuin_osc133_wrap_prompt() {
    local __atuin_prompt="${PROMPT-}"
    local __atuin_rprompt="${RPROMPT-}"

    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_start/}"
    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_end/}"
    __atuin_rprompt="${__atuin_rprompt//$__atuin_osc133_prompt_start/}"
    __atuin_rprompt="${__atuin_rprompt//$__atuin_osc133_prompt_end/}"

    if [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]]; then
        PROMPT="${__atuin_osc133_prompt_start}${__atuin_prompt}"
        RPROMPT="${__atuin_rprompt}${__atuin_osc133_prompt_end}"
    else
        PROMPT="$__atuin_prompt"
        RPROMPT="$__atuin_rprompt"
    fi
}

_atuin_preexec() {
    local id
    id=$(ATUIN_SHELL=zsh atuin history start --hook -- "$1" 2>/dev/null)
    export ATUIN_HISTORY_ID="$id"
    __atuin_osc133_command_executed
    __atuin_preexec_time=${EPOCHREALTIME-}
}

_atuin_precmd() {
    local EXIT="$?" __atuin_precmd_time=${EPOCHREALTIME-}

    __atuin_osc133_wrap_prompt

    [[ -z "${ATUIN_HISTORY_ID:-}" ]] && return

    local duration=""
    if [[ -n $__atuin_preexec_time && -n $__atuin_precmd_time ]]; then
        printf -v duration %.0f $(((__atuin_precmd_time - __atuin_preexec_time) * 1000000000))
    fi

    __atuin_osc133_command_finished "$EXIT"
    (atuin history end --hook --exit $EXIT ${duration:+--duration=$duration} -- $ATUIN_HISTORY_ID >/dev/null 2>&1 &)
    export ATUIN_HISTORY_ID=""
}

# Allow comment lines at the interactive prompt, matching the default
# behavior of bash and fish (oh-my-zsh also enables this).
setopt interactive_comments

# With interactive_comments, a line starting with '#' is added to history
# without executing anything, so preexec never fires for it. Record such
# lines from the history hook instead.
_atuin_zshaddhistory() {
    # Guard in case the user unset the option after atuin init: the line then
    # executes as a normal command and is recorded by preexec/precmd.
    [[ -o interactive_comments ]] || return 0
    local line=${1%$'\n'}
    # Skip multi-line buffers: anything after the comment executes, so the
    # whole buffer is recorded by preexec/precmd.
    [[ $line == \#* && $line != *$'\n'* ]] || return 0
    local id
    id=$(ATUIN_SHELL=zsh atuin history start --hook -- "$line" 2>/dev/null)
    [[ -n $id ]] && (atuin history end --hook --exit 0 --duration=0 -- "$id" >/dev/null 2>&1 &)
    return 0
}

# Check if tmux popup is available (tmux >= 3.2)
__atuin_tmux_popup_check() {
    [[ -n "${TMUX-}" ]] || return 1
    [[ "${ATUIN_TMUX_POPUP:-true}" != "false" ]] || return 1

    # https://github.com/tmux/tmux/wiki/FAQ#how-often-is-tmux-released-what-is-the-version-number-scheme
    local tmux_version
    tmux_version=$(tmux -V 2>/dev/null | sed -n 's/^[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p') # Could have used grep...
    [[ -z "$tmux_version" ]] && return 1

    local m1 m2
    m1=${tmux_version%%.*}
    m2=${tmux_version#*.}
    m2=${m2%%.*}
    [[ "$m1" =~ ^[0-9]+$ ]] || return 1
    [[ "$m2" =~ ^[0-9]+$ ]] || m2=0
    (( m1 > 3 || (m1 == 3 && m2 >= 2) ))
}

# Use global variable to fix scope issues with traps
__atuin_popup_tmpdir=""
__atuin_tmux_popup_cleanup() {
    [[ -n "$__atuin_popup_tmpdir" && -d "$__atuin_popup_tmpdir" ]] && command rm -rf "$__atuin_popup_tmpdir"
    __atuin_popup_tmpdir=""
}

__atuin_search_cmd() {
    local -a search_args=("$@")

    if __atuin_tmux_popup_check; then
        __atuin_popup_tmpdir=$(mktemp -d) || return 1
        local result_file="$__atuin_popup_tmpdir/result"

        trap '__atuin_tmux_popup_cleanup' EXIT HUP INT TERM

        local escaped_query escaped_args
        escaped_query=$(printf '%s' "$BUFFER" | sed "s/'/'\\\\''/g")
        escaped_args=""
        for arg in "${search_args[@]}"; do
            escaped_args+=" '$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")'"
        done

        # In the popup, atuin goes to terminal, stderr goes to file
        local cdir popup_width popup_height
        cdir=$(pwd)
        popup_width="${ATUIN_TMUX_POPUP_WIDTH:-80%}" # Keep default value anyways
        popup_height="${ATUIN_TMUX_POPUP_HEIGHT:-60%}"
        tmux display-popup -d "$cdir" -w "$popup_width" -h "$popup_height" -E -E -- \
            sh -c "PATH='$PATH' ATUIN_SESSION='$ATUIN_SESSION' ATUIN_SHELL=zsh ATUIN_QUERY='$escaped_query' atuin search $escaped_args -i 2>'$result_file'"

        if [[ -f "$result_file" ]]; then
            cat "$result_file"
        fi

        __atuin_tmux_popup_cleanup
        trap - EXIT HUP INT TERM
    else
        ATUIN_SHELL=zsh ATUIN_QUERY=$BUFFER atuin search "${search_args[@]}" -i 3>&1 1>&2 2>&3 3>&-
    fi
}

_atuin_search() {
    emulate -L zsh
    zle -I

    # swap stderr and stdout, so that the tui stuff works
    # TODO: not this
    local output __atuin_status
    # shellcheck disable=SC2048
    output=$(__atuin_search_cmd $*)
    __atuin_status=$?

    zle reset-prompt
    # re-enable bracketed paste
    # shellcheck disable=SC2154
    echo -n ${zle_bracketed_paste[1]} >/dev/tty

    if (( __atuin_status != 0 )); then
        [[ -n $output ]] && print -r -- "$output" >/dev/tty
        return $__atuin_status
    fi

    if [[ -n $output ]]; then
        RBUFFER=""
        LBUFFER=$output

        if [[ $LBUFFER == __atuin_accept__:* ]]
        then
            LBUFFER=${LBUFFER#__atuin_accept__:}
            zle accept-line
        fi
    fi
}
_atuin_search_vicmd() {
    _atuin_search --keymap-mode=vim-normal
}
_atuin_search_viins() {
    _atuin_search --keymap-mode=vim-insert
}

_atuin_up_search() {
    # Only trigger if the buffer is a single line
    if [[ ! $BUFFER == *$'\n'* ]]; then
        _atuin_search --shell-up-key-binding "$@"
    else
        zle up-line
    fi
}
_atuin_up_search_vicmd() {
    _atuin_up_search --keymap-mode=vim-normal
}
_atuin_up_search_viins() {
    _atuin_up_search --keymap-mode=vim-insert
}

add-zsh-hook preexec _atuin_preexec
add-zsh-hook precmd _atuin_precmd
add-zsh-hook zshaddhistory _atuin_zshaddhistory

zle -N atuin-search _atuin_search
zle -N atuin-search-vicmd _atuin_search_vicmd
zle -N atuin-search-viins _atuin_search_viins
zle -N atuin-up-search _atuin_up_search
zle -N atuin-up-search-vicmd _atuin_up_search_vicmd
zle -N atuin-up-search-viins _atuin_up_search_viins

# These are compatibility widget names for "atuin <= 17.2.1" users.
zle -N _atuin_search_widget _atuin_search
zle -N _atuin_up_search_widget _atuin_up_search
bindkey -M emacs '^r' atuin-search
bindkey -M viins '^r' atuin-search-viins
bindkey -M vicmd '/' atuin-search
bindkey -M emacs '^[[A' atuin-up-search
bindkey -M vicmd '^[[A' atuin-up-search-vicmd
bindkey -M viins '^[[A' atuin-up-search-viins
bindkey -M emacs '^[OA' atuin-up-search
bindkey -M vicmd '^[OA' atuin-up-search-vicmd
bindkey -M viins '^[OA' atuin-up-search-viins
bindkey -M vicmd 'k' atuin-up-search-vicmd
_atuin_ai_cleanup() {
    true
}

# zle reset-prompt anchors the repaint at the cursor row: a multi-line
# prompt grows *upward*, overwriting whatever the inline TUI left on the
# rows above. Pad with prompt-height - 1 newlines first so the repaint
# lands on blank rows below the conversation instead.
_atuin_ai_reset_prompt() {
    local -a _prompt_lines=("${(@f)${(%%)PROMPT}}")
    local -i _pad=$(( ${#_prompt_lines} - 1 ))
    (( _pad > 0 )) && printf '\n%.0s' {1..$_pad} >/dev/tty
    zle reset-prompt
}

# Question mark at start of line - natural language mode.
# Named with 'self-' prefix so bracketed-paste-magic activates it during
# paste, allowing url-quote-magic to escape ? in pasted URLs via self-insert.
self-atuin-ai-question-mark() {
    # If buffer is empty or just contains '?', trigger natural language mode
    if [[ -z "$BUFFER" || "$BUFFER" == "?" ]]; then
        BUFFER=""
        # Close the semantic prompt zone (OSC 133 C, "command output
        # starts") before handing the terminal to the TUI. Without it,
        # terminals with shell integration (Ghostty) believe we are
        # still at the prompt, and their resize-time prompt reflow
        # erases everything below the prompt mark — including the
        # conversation the TUI printed.
        printf '\033]133;C\007' > /dev/tty
        local output
        output=$(atuin ai inline --hook 3>&1 1>&2 2>&3)

        # Clean up the inline viewport
        _atuin_ai_cleanup

        if [[ $output == __atuin_ai_print__:* ]]; then
            echo "${output#__atuin_ai_print__:}"
            _atuin_ai_reset_prompt
        elif [[ $output == __atuin_ai_cancel__ ]]; then
            _atuin_ai_reset_prompt
        elif [[ $output == __atuin_ai_execute__:* ]]; then
            RBUFFER=""
            LBUFFER=${output#__atuin_ai_execute__:}
            _atuin_ai_reset_prompt
            zle accept-line
        elif [[ $output == __atuin_ai_insert__:* ]]; then
            RBUFFER=""
            LBUFFER=${output#__atuin_ai_insert__:}
            _atuin_ai_reset_prompt
        elif [[ -n $output ]]; then
            RBUFFER=""
            LBUFFER=$output
            _atuin_ai_reset_prompt
        else
            _atuin_ai_reset_prompt
        fi
    else
        zle self-insert
    fi
}

# Set up keybindings
zle -N self-atuin-ai-question-mark
bindkey '?' self-atuin-ai-question-mark # Question mark

# --- fnm init ---
export PATH="/run/user/1000/fnm_multishells/12467_1787724455246/bin":$PATH
export FNM_MULTISHELL_PATH="/run/user/1000/fnm_multishells/12467_1787724455246"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_DIR="/home/john/.local/share/fnm"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="true"
export FNM_ARCH="x64"
autoload -U add-zsh-hook
_fnm_autoload_hook () {
    if [[ -f .node-version || -f .nvmrc || -f package.json ]]; then
    fnm use --silent-if-unchanged
fi

}

add-zsh-hook chpwd _fnm_autoload_hook \
    && _fnm_autoload_hook

rehash

# --- fzf init ---
### key-bindings.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_COMMAND
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS


# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

{
if [[ -o interactive ]]; then

#----BEGIN INCLUDE common.sh
# NOTE: Do not directly edit this section, which is copied from "common.sh".
# To modify it, one can edit "common.sh" and run "./update.sh" to apply
# the changes. See code comments in "common.sh" for the implementation details.

__fzf_defaults() {
  printf '%s\n' "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  printf '%s\n' "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_exec_awk() {
  if [[ -z ${__fzf_awk-} ]]; then
    __fzf_awk=awk
    if [[ $OSTYPE == solaris* && -x /usr/xpg4/bin/awk ]]; then
      __fzf_awk=/usr/xpg4/bin/awk
    elif command -v mawk > /dev/null 2>&1; then
      local n x y z d
      IFS=' .' read -r n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] &&
        (((x * 1000 + y) * 1000 + z >= 1003004)) 2> /dev/null &&
        ((d >= 20230302)) 2> /dev/null &&
        __fzf_awk=mawk
    fi
  fi
  LC_ALL=C exec "$__fzf_awk" "$@"
}
#----END INCLUDE

# CTRL-T - Paste the selected file path(s) into the command line
__fzf_select() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
  FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
  FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" < /dev/tty | while read -r item; do
    echo -n -E "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fzf_select)"
  local ret=$?
  zle reset-prompt
  return $ret
}
if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
  zle     -N            fzf-file-widget
  bindkey -M emacs '^T' fzf-file-widget
  bindkey -M vicmd '^T' fzf-file-widget
  bindkey -M viins '^T' fzf-file-widget
fi

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
if [[ "${FZF_ALT_C_COMMAND-x}" != "" ]]; then
  zle     -N             fzf-cd-widget
  bindkey -M emacs '\ec' fzf-cd-widget
  bindkey -M vicmd '\ec' fzf-cd-widget
  bindkey -M viins '\ec' fzf-cd-widget
fi

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | __fzf_exec_awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  if [ -n "$selected" ]; then
    if [[ $(__fzf_exec_awk '{print $1; exit}' <<< "$selected") =~ ^[1-9][0-9]* ]]; then
      zle vi-fetch-history -n $MATCH
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  zle reset-prompt
  return $ret
}
if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
  if [[ -n ${FZF_CTRL_R_COMMAND-} ]]; then
    echo "warning: FZF_CTRL_R_COMMAND is set to a custom command, but custom commands are not yet supported for CTRL-R" >&2
  fi
  zle     -N            fzf-history-widget
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
fi
fi

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
### end: key-bindings.zsh ###
### completion.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ completion.zsh
#
# - $FZF_TMUX                 (default: 0)
# - $FZF_TMUX_OPTS            (default: empty)
# - $FZF_COMPLETION_TRIGGER   (default: '**')
# - $FZF_COMPLETION_OPTS      (default: empty)
# - $FZF_COMPLETION_PATH_OPTS (default: empty)
# - $FZF_COMPLETION_DIR_OPTS  (default: empty)


# Both branches of the following `if` do the same thing -- define
# __fzf_completion_options such that `eval $__fzf_completion_options` sets
# all options to the same values they currently have. We'll do just that at
# the bottom of the file after changing options to what we prefer.
#
# IMPORTANT: Until we get to the `emulate` line, all words that *can* be quoted
# *must* be quoted in order to prevent alias expansion. In addition, code must
# be written in a way works with any set of zsh options. This is very tricky, so
# careful when you change it.
#
# Start by loading the builtin zsh/parameter module. It provides `options`
# associative array that stores current shell options.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  # This is the fast branch and it gets taken on virtually all Zsh installations.
  #
  # ${(kv)options[@]} expands to array of keys (option names) and values ("on"
  # or "off"). The subsequent expansion# with (j: :) flag joins all elements
  # together separated by spaces. __fzf_completion_options ends up with a value
  # like this: "options=(shwordsplit off aliases on ...)".
  __fzf_completion_options="options=(${(j: :)${(kv)options[@]}})"
else
  # This branch is much slower because it forks to get the names of all
  # zsh options. It's possible to eliminate this fork but it's not worth the
  # trouble because this branch gets taken only on very ancient or broken
  # zsh installations.
  () {
    # That `()` above defines an anonymous function. This is essentially a scope
    # for local parameters. We use it to avoid polluting global scope.
    'local' '__fzf_opt'
    __fzf_completion_options="setopt"
    # `set -o` prints one line for every zsh option. Each line contains option
    # name, some spaces, and then either "on" or "off". We just want option names.
    # Expansion with (@f) flag splits a string into lines. The outer expansion
    # removes spaces and everything that follow them on every line. __fzf_opt
    # ends up iterating over option names: shwordsplit, aliases, etc.
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        # Option $__fzf_opt is currently on, so remember to set it back on.
        __fzf_completion_options+=" -o $__fzf_opt"
      else
        # Option $__fzf_opt is currently off, so remember to set it back off.
        __fzf_completion_options+=" +o $__fzf_opt"
      fi
    done
    # The value of __fzf_completion_options here looks like this:
    # "setopt +o shwordsplit -o aliases ..."
  }
fi

# Enable the default zsh options (those marked with <Z> in `man zshoptions`)
# but without `aliases`. Aliases in functions are expanded when functions are
# defined, so if we disable aliases here, we'll be sure to have no pesky
# aliases in any of our functions. This way we won't need prefix every
# command with `command` or to quote every word to defend against global
# aliases. Note that `aliases` is not the only option that's important to
# control. There are several others that could wreck havoc if they are set
# to values we don't expect. With the following `emulate` command we
# sidestep this issue entirely.
'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

# This brace is the start of try-always block. The `always` part is like
# `finally` in lesser languages. We use it to *always* restore user options.
{
# The 'emulate' command should not be placed inside the interactive if check;
# placing it there fails to disable alias expansion. See #3731.
if [[ -o interactive ]]; then

# To use custom commands instead of find, override _fzf_compgen_{path,dir}
#
#   _fzf_compgen_path() {
#     echo "$1"
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }
#
#   _fzf_compgen_dir() {
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }

###########################################################

#----BEGIN INCLUDE common.sh
# NOTE: Do not directly edit this section, which is copied from "common.sh".
# To modify it, one can edit "common.sh" and run "./update.sh" to apply
# the changes. See code comments in "common.sh" for the implementation details.

__fzf_defaults() {
  printf '%s\n' "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  printf '%s\n' "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_exec_awk() {
  if [[ -z ${__fzf_awk-} ]]; then
    __fzf_awk=awk
    if [[ $OSTYPE == solaris* && -x /usr/xpg4/bin/awk ]]; then
      __fzf_awk=/usr/xpg4/bin/awk
    elif command -v mawk > /dev/null 2>&1; then
      local n x y z d
      IFS=' .' read -r n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] &&
        (((x * 1000 + y) * 1000 + z >= 1003004)) 2> /dev/null &&
        ((d >= 20230302)) 2> /dev/null &&
        __fzf_awk=mawk
    fi
  fi
  LC_ALL=C exec "$__fzf_awk" "$@"
}
#----END INCLUDE

__fzf_comprun() {
  if [[ "$(type _fzf_comprun 2>&1)" =~ function ]]; then
    _fzf_comprun "$@"
  elif [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; }; then
    shift
    if [ -n "${FZF_TMUX_OPTS-}" ]; then
      fzf-tmux ${(Q)${(Z+n+)FZF_TMUX_OPTS}} -- "$@"
    else
      fzf-tmux -d ${FZF_TMUX_HEIGHT:-40%} -- "$@"
    fi
  else
    shift
    fzf "$@"
  fi
}

# Extract the name of the command. e.g. ls; foo=1 ssh **<tab>
__fzf_extract_command() {
  # Control completion with the "compstate" parameter, insert and list nothing
  compstate[insert]=
  compstate[list]=
  cmd_word="${(Q)words[1]}"
}

__fzf_generic_path_completion() {
  local base lbuf compgen fzf_opts suffix tail dir leftover matches
  base=$1
  lbuf=$2
  compgen=$3
  fzf_opts=$4
  suffix=$5
  tail=$6

  setopt localoptions nonomatch
  if [[ $base = *'$('* ]] || [[ $base = *'<('* ]] || [[ $base = *'>('* ]] || [[ $base = *':='* ]] || [[ $base = *'`'* ]]; then
    return
  fi
  eval "base=$base" 2> /dev/null || return
  [[ $base = *"/"* ]] && dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      matches=$(
        export FZF_DEFAULT_OPTS
        FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --scheme=path" "${FZF_COMPLETION_OPTS-}")
        unset FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS_FILE
        if declare -f "$compgen" > /dev/null; then
          eval "$compgen $(printf %q "$dir")" | __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover"
        else
          if [[ $compgen =~ dir ]]; then
            walker=dir,follow
            rest=${FZF_COMPLETION_DIR_OPTS-}
          else
            walker=file,dir,follow,hidden
            rest=${FZF_COMPLETION_PATH_OPTS-}
          fi
          __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover" --walker "$walker" --walker-root="$dir" ${(Q)${(Z+n+)rest}} < /dev/tty
        fi | while read -r item; do
          item="${item%$suffix}$suffix"
          echo -n -E "${(q)item} "
        done
      )
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle reset-prompt
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_fzf_path_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_path \
    "-m" "" " "
}

_fzf_dir_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_dir \
    "" "/" ""
}

_fzf_feed_fifo() {
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &|
}

_fzf_complete() {
  setopt localoptions ksh_arrays
  # Split arguments around --
  local args rest str_arg i sep
  args=("$@")
  sep=
  for i in {0..${#args[@]}}; do
    if [[ "${args[$i]-}" = -- ]]; then
      sep=$i
      break
    fi
  done
  if [[ -n "$sep" ]]; then
    str_arg=
    rest=("${args[@]:$((sep + 1)):${#args[@]}}")
    args=("${args[@]:0:$sep}")
  else
    str_arg=$1
    args=()
    shift
    rest=("$@")
  fi

  local fifo lbuf matches post
  fifo="${TMPDIR:-/tmp}/fzf-complete-fifo-$$"
  lbuf=${rest[0]}
  post="${funcstack[1]}_post"
  type $post > /dev/null 2>&1 || post=cat

  _fzf_feed_fifo "$fifo"
  matches=$(
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse" "${FZF_COMPLETION_OPTS-} $str_arg") \
    FZF_DEFAULT_OPTS_FILE='' \
      __fzf_comprun "$cmd_word" "${args[@]}" -q "${(Q)prefix}" < "$fifo" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  command rm -f "$fifo"
}

# To use custom hostname lists, override __fzf_list_hosts.
# The function is expected to print hostnames, one per line as well as in the
# desired sorting and with any duplicates removed, to standard output.
if ! declare -f __fzf_list_hosts > /dev/null; then
  __fzf_list_hosts() {
    command sort -u \
      <(
        # Note: To make the pathname expansion of "~/.ssh/config.d/*" work
        # properly, we need to adjust the related shell options.  We need to
        # unset "NO_GLOB" (or reset "GLOB"), which disable the pathname
        # expansion totally.  We need to unset "DOT_GLOB" and set "CASE_GLOB"
        # to avoid matching unwanted files.  We need to set "NULL_GLOB" to
        # avoid attempting to read the literal filename '~/.ssh/config.d/*'
        # when no matching is found.
        setopt GLOB NO_DOT_GLOB CASE_GLOB NO_NOMATCH NULL_GLOB

        __fzf_exec_awk '
          # Note: mawk <= 1.3.3-20090705 does not support the POSIX brackets of
          # the form [[:blank:]], and Ubuntu 18.04 LTS still uses this
          # 16-year-old mawk unfortunately.  We need to use [ \t] instead.
          match(tolower($0), /^[ \t]*host(name)?[ \t]*[ \t=]/) {
            $0 = substr($0, RLENGTH + 1) # Remove "Host(name)?=?"
            sub(/#.*/, "")
            for (i = 1; i <= NF; i++)
              if ($i !~ /[*?%]/)
                print $i
          }
        ' ~/.ssh/config ~/.ssh/config.d/* /etc/ssh/ssh_config 2> /dev/null
      ) \
      <(
        __fzf_exec_awk -F ',' '
          match($0, /^[][a-zA-Z0-9.,:-]+/) {
            $0 = substr($0, 1, RLENGTH)
            gsub(/[][]|:[^,]*/, "")
            for (i = 1; i <= NF; i++)
              print $i
          }
        ' ~/.ssh/known_hosts 2> /dev/null
      ) \
      <(
        __fzf_exec_awk '
          {
            sub(/#.*/, "")
            for (i = 2; i <= NF; i++)
              if ($i != "0.0.0.0")
                print $i
          }
        ' /etc/hosts 2> /dev/null
      )
  }
fi

_fzf_complete_telnet() {
  _fzf_complete +m -- "$@" < <(__fzf_list_hosts)
}

# The first and the only argument is the LBUFFER without the current word that contains the trigger.
# The current word without the trigger is in the $prefix variable passed from the caller.
_fzf_complete_ssh() {
  local -a tokens
  tokens=(${(z)1})
  case ${tokens[-1]} in
    -i|-F|-E)
      _fzf_path_completion "$prefix" "$1"
      ;;
    *)
      local user
      [[ $prefix =~ @ ]] && user="${prefix%%@*}@"
      _fzf_complete +m -- "$@" < <(__fzf_list_hosts | __fzf_exec_awk -v user="$user" '{print user $0}')
      ;;
  esac
}

_fzf_complete_export() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unset() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unalias() {
  _fzf_complete +m -- "$@" < <(
    alias | sed 's/=.*//'
  )
}

_fzf_complete_kill() {
  local transformer
  transformer='
    if [[ $FZF_KEY =~ ctrl|alt|shift ]] && [[ -n $FZF_NTH ]]; then
      nths=( ${FZF_NTH//,/ } )
      new_nths=()
      found=0
      for nth in ${nths[@]}; do
        if [[ $nth = $FZF_CLICK_HEADER_NTH ]]; then
          found=1
        else
          new_nths+=($nth)
        fi
      done
      [[ $found = 0 ]] && new_nths+=($FZF_CLICK_HEADER_NTH)
      new_nths=${new_nths[*]}
      new_nths=${new_nths// /,}
      echo "change-nth($new_nths)+change-prompt($new_nths> )"
    else
      if [[ $FZF_NTH = $FZF_CLICK_HEADER_NTH ]]; then
        echo "change-nth()+change-prompt(> )"
      else
        echo "change-nth($FZF_CLICK_HEADER_NTH)+change-prompt($FZF_CLICK_HEADER_WORD> )"
      fi
    fi
  '
  _fzf_complete -m --header-lines=1 --no-preview --wrap --color fg:dim,nth:regular \
    --bind "click-header:transform:$transformer" -- "$@" < <(
    command ps -eo user,pid,ppid,start,time,command 2> /dev/null ||
      command ps -eo user,pid,ppid,time,args 2> /dev/null || # For BusyBox
      command ps --everyone --full --windows # For cygwin
  )
}

_fzf_complete_kill_post() {
  __fzf_exec_awk '{print $2}'
}

fzf-completion() {
  local tokens prefix trigger tail matches lbuf d_cmds cursor_pos cmd_word
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [[ -z $trigger && ${LBUFFER[-1]} == ' ' ]] && tokens+=("")

  # When the trigger starts with ';', it becomes a separate token
  if [[ ${LBUFFER} = *"${tokens[-2]-}${tokens[-1]}" ]]; then
    tokens[-2]="${tokens[-2]-}${tokens[-1]}"
    tokens=(${tokens[0,-2]})
  fi

  lbuf=$LBUFFER
  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}

  # Trigger sequence given
  if [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS-cd pushd rmdir})

    {
      cursor_pos=$CURSOR
      # Move the cursor before the trigger to preserve word array elements when
      # trigger chars like ';' or '`' would otherwise reset the 'words' array.
      CURSOR=$((cursor_pos - ${#trigger} - 1))
      # Check if at least one completion system (old or new) is active.
      # If at least one user-defined completion widget is detected, nothing will
      # be completed if neither the old nor the new completion system is enabled.
      # In such cases, the 'zsh/compctl' module is loaded as a fallback.
      if ! zmodload -F zsh/parameter p:functions 2>/dev/null || ! (( ${+functions[compdef]} )); then
        zmodload -F zsh/compctl 2>/dev/null
      fi
      # Create a completion widget to access the 'words' array (man zshcompwid)
      zle -C __fzf_extract_command .complete-word __fzf_extract_command
      zle __fzf_extract_command
    } always {
      CURSOR=$cursor_pos
      # Delete the completion widget
      zle -D __fzf_extract_command  2>/dev/null
    }

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    if [[ $prefix = *'$('* ]] || [[ $prefix = *'<('* ]] || [[ $prefix = *'>('* ]] || [[ $prefix = *':='* ]] || [[ $prefix = *'`'* ]]; then
      return
    fi
    [ -n "${tokens[-1]}" ] && lbuf=${lbuf:0:-${#tokens[-1]}}

    if eval "noglob type _fzf_complete_${cmd_word} >/dev/null"; then
      prefix="$prefix" eval _fzf_complete_${cmd_word} ${(q)lbuf}
      zle reset-prompt
    elif [ ${d_cmds[(i)$cmd_word]} -le ${#d_cmds} ]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}

[ -z "$fzf_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fzf_default_completion=$binding[(s: :w)2]
  unset binding
}

# Normal widget
zle     -N   fzf-completion
bindkey '^I' fzf-completion
fi

} always {
  # Restore the original options.
  eval $__fzf_completion_options
  'unset' '__fzf_completion_options'
}
### end: completion.zsh ###

# --- carapace init ---
# export PATH="/home/john/.config/carapace/bin:$PATH"

get-env () { echo "${(P)1}"; }
set-env () { export "$1=$2"; }
unset-env () { unset "$1"; }

function _carapace_completer {
  local command="$(basename $words[1])"
  local compline=${words[@]:0:$CURRENT}
  local IFS=$'\n'
  local lines

  declare -x CARAPACE_COMPLINE="${words}"
  declare -x CARAPACE_ZSH_HASH_DIRS="$(hash -d)"
  declare -x CARAPACE_SHELL=zsh
  declare -x CARAPACE_SHELL_ALIASES="${(k)aliases}"
  declare -x CARAPACE_SHELL_BUILTINS="$(print -roC1 -- ${(k)builtins})"
  declare -x CARAPACE_SHELL_FUNCTIONS="$(print -l ${(ok)functions})"
  declare -x CARAPACE_SHELL_JOBS="$(print -l ${${(k)jobtexts}/#/%%})"
  declare -x CARAPACE_SHELL_VARIABLES="$(print -l ${(ok)parameters})"

  # shellcheck disable=SC2086,SC2154,SC2155
  lines="$(echo "${compline}''" | xargs carapace "${command}" zsh 2>/dev/null)"
  if [ $? -eq 1 ]; then
    lines="$(echo "${compline}'" | xargs carapace "${command}" zsh 2>/dev/null)"
    if [ $? -eq 1 ]; then
      lines="$(echo "${compline}\"" | xargs carapace "${command}" zsh 2>/dev/null)"
    fi
  fi

  local zstyle message noprefix data
  IFS=$'\001' read -r -d '' zstyle message noprefix data <<<"${lines}"
  # shellcheck disable=SC2154
  zstyle ":completion:${curcontext}:*" list-colors "${zstyle}"
  zstyle ":completion:${curcontext}:*" group-name ''
  [ -z "$message" ] || _message -r "${message}"
  [[ "${noprefix}" = "true" ]] && compstate[insert]=menu

  local block tag displays values displaysArr valuesArr
  while IFS=$'\002' read -r -d $'\002' block; do
    IFS=$'\003' read -r -d '' tag displays values <<<"${block}"
    # shellcheck disable=SC2034
    IFS=$'\n' read -r -d $'\004' -A displaysArr <<<"${displays}"$'\004'
    IFS=$'\n' read -r -d $'\004' -A valuesArr <<<"${values}"$'\004'

    [[ ${#valuesArr[@]} -gt 1 ]] && _describe -t "${tag}" "${tag}" displaysArr valuesArr -Q -S ''
  done <<<"${data}"
}

compdef _carapace_completer "000_bash_completion_compat" "2to3" "5g" "5l" "6g" "6l" "7z" "7za" "7zr" "7zz" "7zzs" "8g" "8l" "Mosaic" "SuSEconfig" "a2dismod" "a2dissite" "a2enmod" "a2ensite" "a2ps" "a2x" "aaaa" "aap" "aapt" "abcde" "abook" "ack" "ack-grep" "ack-standalone" "ack2" "aclocal" "aclocal-1.10" "aclocal-1.11" "aclocal-1.12" "aclocal-1.13" "aclocal-1.14" "aclocal-1.15" "aclocal-1.16" "acpi" "acpid" "acpitool" "acroread" "act" "adb" "add-apt-repository" "add-zle-hook-widget" "add-zsh-hook" "add_members" "admin" "age" "agg" "ali" "alpine" "alsamixer" "alternatives" "amaya" "analyseplugin" "animate" "anno" "ansible" "ansible-config" "ansible-console" "ansible-creator" "ansible-doc" "ansible-galaxy" "ansible-inventory" "ansible-playbook" "ansible-pull" "ansible-vault" "ant" "antiword" "aodh" "aoss" "apache2ctl" "apachectl" "apk" "apko" "apksigner" "aplay" "apm" "appdata-validate" "appletviewer" "apport-bug" "apport-cli" "apport-collect" "apport-unpack" "appstreamcli" "apptainer" "apropos" "apt" "apt-add-repository" "apt-build" "apt-cache" "apt-cdrom" "apt-config" "apt-file" "apt-get" "apt-mark" "apt-move" "apt-show-versions" "aptitude" "aptitude-curses" "apvlv" "aqua" "ar" "arch" "archlinux-java" "arduino-ctags" "arecord" "arena" "argo" "argocd" "aria2c" "arm-koji" "arp" "arping" "arpspoof" "artisan" "asciidoc" "asciidoc.py" "asciidoctor" "asciinema" "ash" "aspell" "at" "atq" "atrm" "attr" "atuin" "augtool" "auto-apt" "autoconf" "autoheader" "automake" "automake-1.10" "automake-1.11" "automake-1.12" "automake-1.13" "automake-1.14" "automake-1.15" "automake-1.16" "autoreconf" "autorpm" "autoscan" "autossh" "autoupdate" "avahi-browse" "avahi-browse-domains" "avahi-resolve" "avahi-resolve-address" "avahi-resolve-host-name" "avctrl" "avdmanager" "awk" "aws" "axi-cache" "az" "b2sum" "badblocks" "baobab" "barbican" "base32" "base64" "basename" "basenc" "bash" "bash-language-server" "bat" "batcat" "batch" "batdiff" "batgrep" "batman" "bats" "baz" "bazel" "bc" "beadm" "beep" "benthos" "bibtex" "bison" "bk" "black" "blkdiscard" "blkid" "blockdev" "bloop" "bluetoothctl" "bmake" "bogofilter" "bogotune" "bogoutil" "boundary" "bpftool" "bpftrace" "bpython" "bpython-gtk" "bpython-urwid" "bpython2" "bpython2-gtk" "bpython2-urwid" "bpython3" "bpython3-gtk" "bpython3-urwid" "brctl" "brew" "brotli" "bru" "bsdconfig" "bsdgrep" "bsdinstall" "bsdtar" "btdownloadcurses" "btdownloadcurses.py" "btdownloadgui" "btdownloadgui.py" "btdownloadheadless" "btdownloadheadless.py" "btlaunchmany" "btlaunchmanycurses" "btmakemetafile" "btop" "btreannounce" "btrename" "btrfs" "bts" "btshowmetainfo" "bttrack" "bug" "buildctl" "buildhash" "bun" "bunx" "bunzip2" "burst" "busctl" "but" "bwrap" "bzegrep" "bzfgrep" "bzgrep" "bzip2" "bzip2recover" "bzr" "c++" "cabal" "caffeinate" "cal" "calendar" "calibre" "cancel" "capslock" "carapace" "cardctl" "cargo" "cargo-clippy" "cargo-fmt" "cargo-metadata" "cargo-rm" "cargo-set-version" "cargo-upgrade" "cargo-watch" "carton" "cat" "catchsegv" "cc" "ccache" "ccal" "ccze" "cdbs-edit-patch" "cdc" "cdcd" "cdebug" "cdr" "cdrdao" "cdrecord" "ceilometer" "cekit" "certtool" "cfagent" "cfdisk" "cfrun" "cftp" "chage" "change_pw" "charm" "chattr" "chcon" "chcpu" "chdman" "check_db" "check_perms" "checksec" "cheese" "chezmoi" "chflags" "chfn" "chgrp" "chimera" "chkconfig" "chkstow" "chmod" "choom" "chown" "chpass" "chpasswd" "chroma" "chrome" "chromium" "chromium-browser" "chronyc" "chroot" "chrpath" "chrt" "chsh" "ci" "cifsiostat" "cinder" "ciptool" "circleci" "civclient" "civserver" "ckeygen" "cksfv" "cksum" "clamav-config" "clamav-milter" "clambc" "clamconf" "clamd" "clamdscan" "clamdtop" "clamonacc" "clamscan" "clamsubmit" "clang" "clang++" "clay" "cleanarch" "clear" "clion" "clisp" "clone_member" "cloud-init" "cloudkitty" "clusterdb" "clzip" "cmp" "cmus" "co" "code" "code-insiders" "codecov" "codex" "col" "colcrt" "colima" "colormake" "colormgr" "colrm" "column" "comb" "combine" "combinediff" "comm" "comp" "compare" "composer" "composer.phar" "composite" "compress" "conch" "conda" "conda-content-trust" "conda-env" "config.status" "config_list" "configure" "conjure" "conky" "consul" "convert" "coreadm" "coredumpctl" "cosign" "cowsay" "cowthink" "cp" "cpan2dist" "cpio" "cplay" "cppcheck" "cpupower" "crc" "createdb" "createuser" "crontab" "crsh" "crush" "cryptdisks_start" "cryptdisks_stop" "cryptsetup" "cscope" "csh" "csplit" "cssh" "csup" "csview" "ctags" "ctags-exuberant" "ctags-universal" "cu" "cue" "cura" "curl" "cut" "cvs" "cvsps" "cvsup" "cygcheck" "cygcheck.exe" "cygpath" "cygpath.exe" "cygrunsrv" "cygrunsrv.exe" "cygserver" "cygserver.exe" "cygstart" "cygstart.exe" "d2" "dagger" "dak" "darcs" "darktable" "darktable-cli" "dart" "dash" "datagrip" "dataspell" "date" "dbt" "dbus-launch" "dbus-monitor" "dbus-send" "dc" "dchroot" "dchroot-dsa" "dconf" "dcop" "dcopclient" "dcopfind" "dcopobject" "dcopref" "dcopstart" "dcut" "dd" "deadcode" "debchange" "debcheckout" "debconf" "debconf-show" "debdiff" "debfoster" "deborphan" "debsign" "debsnap" "debuild" "defaults" "deja-dup" "delta" "deno" "designate" "desktop-file-validate" "devbox" "devcontainer" "devlink" "devpod" "devtodo" "df" "dfc" "dfutool" "dhclient" "dhclient3" "dhcpinfo" "dict" "diff" "diff3" "diffstat" "dig" "dillo" "dir" "dircmp" "dircolors" "direnv" "dirname" "display" "dist" "dive" "django-admin" "django-admin.py" "dkms" "dladm" "dlocate" "dlv" "dmake" "dmenu" "dmesg" "dmidecode" "dms" "dmypy" "dnf" "dnf-2" "dnf-3" "dngconverter" "dnsmasq" "dnssec-keygen" "dnsspoof" "doas" "docker" "docker-buildx" "docker-compose" "docker-scan" "dockerd" "doctl" "doing" "domainname" "dos2unix" "dosdel" "dosread" "dot" "downgrade" "dpatch-edit-patch" "dpkg" "dpkg-buildpackage" "dpkg-cross" "dpkg-deb" "dpkg-parsechangelog" "dpkg-query" "dpkg-reconfigure" "dpkg-repack" "dpkg-source" "dpll" "dput" "dracut" "drill" "dropbox" "dropdb" "dropuser" "dscverify" "dselect" "dsh" "dsniff" "dtrace" "dtruss" "du" "dumpadm" "dumpdb" "dumpe2fs" "dumper" "dumper.exe" "dupload" "dvibook" "dviconcat" "dvicopy" "dvidvi" "dvipdf" "dvips" "dviselect" "dvitodvi" "dvitype" "dwb" "e2freefrag" "e2label" "eatmydata" "ebook-convert" "ebtables" "ecasound" "ecryptfs-migrate-home" "ed" "edquota" "egrep" "eject" "electron" "elfdump" "elinks" "elvish" "enscript" "entr" "env" "envsubst" "eog" "epdfview" "epsffit" "erb" "espeak" "etags" "ether-wake" "etherwake" "ethtool" "eu-nm" "eu-objdump" "eu-readelf" "eu-strings" "eview" "evim" "evince" "ex" "exa" "exercism" "expand" "explodepkg" "expr" "express" "extcheck" "extractres" "eza" "f77" "f95" "faas-cli" "factor" "faillog" "fakechroot" "fakeroot" "fallocate" "fastboot" "fastfetch" "fbgs" "fbi" "fc-cache" "fc-cat" "fc-conflist" "fc-list" "fc-match" "fd" "fdisk" "feh" "fetch" "fetchmail" "ffmpeg" "ffplay" "ffprobe" "fgrep" "figlet" "file" "file-roller" "filebucket" "filefrag" "filesnarf" "filterdiff" "find" "find_member" "findaffix" "findfs" "findmnt" "finger" "fink" "fio" "firefox" "firefox-esr" "fish" "fixdlsrps" "fixfmps" "fixmacps" "fixpsditps" "fixpspps" "fixscribeps" "fixtpps" "fixwfwps" "fixwpps" "fixwwps" "flac" "flake8" "flatpak" "flex" "flex++" "flipdiff" "flist" "flists" "flock" "flowadm" "flutter" "flyctl" "fmadm" "fmt" "fmttest" "fned" "fnext" "fnm" "fold" "folder" "folders" "foot" "fortune" "forw" "fprev" "fprintd-delete" "fprintd-enroll" "fprintd-list" "fprintd-verify" "free" "freebsd-make" "freebsd-update" "freeciv" "freeciv-gtk2" "freeciv-gtk3" "freeciv-sdl" "freeciv-server" "freeciv-xaw" "freeze" "freezer" "fs_usage" "fsck" "fsfreeze" "fsh" "fstat" "fstrim" "ftp" "ftpd" "function" "fury" "fuser" "fusermount" "fw_update" "fwhois" "fwupdmgr" "fwupdtool" "fzf" "g++" "g++-5" "g++-6" "g++-7" "g++-8" "g4" "g77" "g95" "galeon" "gapplication" "gatsby" "gawk" "gb2sum" "gbase32" "gbase64" "gbasename" "gcat" "gcc" "gcc-5" "gcc-6" "gcc-7" "gcc-8" "gccgo" "gccgo-5" "gccgo-6" "gccgo-7" "gccgo-8" "gchmod" "gchroot" "gcj" "gcksum" "gcl" "gcloud" "gcmp" "gcomm" "gcore" "gcp" "gcut" "gdate" "gdb" "gdbus" "gdctl" "gdd" "gdf" "gdiff" "gdown" "gdu" "geany" "gegrep" "gem" "genaliases" "gendiff" "genisoimage" "genv" "geoiplookup" "geoiplookup6" "get" "get-env" "getafm" "getclip" "getclip.exe" "getconf" "getent" "getfacl" "getfacl.exe" "getfattr" "getmail" "getopt" "gex" "gexpand" "gfgrep" "gfind" "gfmt" "gfold" "gfortran" "gfortran-5" "gfortran-6" "gfortran-7" "gfortran-8" "gftp" "ggetopt" "ggrep" "ggv" "gh" "gh-copilot" "gh-dash" "gh-stack" "ghalint" "ghead" "ghostscript" "ghostty" "ghostview" "gid" "gimp" "ginstall" "gio" "git" "git-abort" "git-alias" "git-archive-file" "git-authors" "git-browse" "git-browse-ci" "git-buildpackage" "git-clang-format" "git-clear" "git-clear-soft" "git-coauthor" "git-cvsserver" "git-extras" "git-info" "git-prompt" "git-receive-pack" "git-shell" "git-standup" "git-unlock" "git-upload-archive" "git-upload-pack" "git-utimes" "gitk" "gitleaks" "gitlint" "gitsign" "gitui" "gjoin" "gkrellm" "gkrellm2" "glab" "glance" "gln" "global" "global-python-argcomplete" "glocate" "glow" "gls" "gm" "gmake" "gmd5sum" "gmkdir" "gmkfifo" "gmknod" "gmktemp" "gmplayer" "gmv" "gnatmake" "gnl" "gnocchi" "gnokii" "gnome-control-center" "gnome-extensions" "gnome-gv" "gnome-keyring" "gnome-keyring-daemon" "gnome-maps" "gnome-mplayer" "gnome-screenshot" "gnome-terminal" "gnumake" "gnumfmt" "gnupod_INIT" "gnupod_addsong" "gnupod_check" "gnupod_search" "gnutls-cli" "gnutls-cli-debug" "gnutls-serv" "go" "go-carpet" "go-tool-asm" "go-tool-buildid" "go-tool-cgo" "go-tool-compile" "go-tool-covdata" "go-tool-cover" "go-tool-dist" "go-tool-doc" "go-tool-fix" "go-tool-link" "go-tool-mockgen" "go-tool-nm" "go-tool-objdump" "go-tool-pack" "gocryptfs" "gocyclo" "god" "gofmt" "goimports" "goland" "golangci-lint" "gomplate" "gonew" "google-chrome" "google-chrome-stable" "gopls" "goreleaser" "goweight" "gparted" "gpasswd" "gpaste" "gpatch" "gpc" "gpg" "gpg-agent" "gpg-zip" "gpg2" "gpgv" "gpgv2" "gphoto2" "gprintenv" "gprof" "gqview" "gradle" "gradlew" "grail" "greadlink" "grep" "grep-excuses" "grepdiff" "gresource" "grm" "grmdir" "groff" "groupadd" "groupdel" "groupmems" "groupmod" "groups" "growisofs" "grpck" "grub" "grub-editenv" "grub-install" "grub-mkconfig" "grub-mkfont" "grub-mkimage" "grub-mkpasswd-pbkdf2" "grub-mkrescue" "grub-probe" "grub-reboot" "grub-script-check" "grub-set-default" "grype" "gs" "gsa" "gsbj" "gsdj" "gsdj500" "gsed" "gseq" "gsettings" "gsha1sum" "gsha224sum" "gsha256sum" "gsha384sum" "gsha512sum" "gshred" "gshuf" "gslj" "gslp" "gsnd" "gsort" "gsplit" "gssdp-device-sniffer" "gssdp-discover" "gst-inspect-1.0" "gst-launch-1.0" "gstat" "gstdbuf" "gstrings" "gstty" "gsum" "gtac" "gtail" "gtar" "gtee" "gtimeout" "gtk4-builder-tool" "gtk4-image-tool" "gtk4-path-tool" "gtk4-rendernode-tool" "gtouch" "gtr" "gtty" "guilt" "guilt-add" "guilt-applied" "guilt-delete" "guilt-files" "guilt-fold" "guilt-fork" "guilt-header" "guilt-help" "guilt-import" "guilt-import-commit" "guilt-init" "guilt-new" "guilt-next" "guilt-patchbomb" "guilt-pop" "guilt-prev" "guilt-push" "guilt-rebase" "guilt-refresh" "guilt-rm" "guilt-series" "guilt-status" "guilt-top" "guilt-unapplied" "gulp" "gum" "guname" "gunexpand" "guniq" "gunzip" "guptime" "gv" "gview" "gvim" "gvimdiff" "gwc" "gwho" "gxargs" "gzegrep" "gzfgrep" "gzgrep" "gzilla" "gzip" "halt" "hardlink" "hatch" "hciattach" "hciconfig" "hcitool" "hcloud" "hd" "hddtemp" "hdiutil" "head" "heat" "helix" "helm" "helmfile" "helmsman" "help" "hexchat" "hexdump" "hid2hci" "hilite" "histed" "host" "hostid" "hostname" "hostnamectl" "hotjava" "hping" "hping2" "hping3" "htop" "htpasswd" "http" "https" "hugetop" "hugo" "hunspell" "hurl" "hwinfo" "hx" "hyperfine" "i3" "i3-scrot" "i3exit" "i3lock" "i3status" "i3status-rs" "ibus" "iceweasel" "icombine" "iconv" "iconvconfig" "id" "idea" "identify" "idn" "ifconfig" "ifdown" "ifquery" "ifstat" "ifstatus" "iftop" "ifup" "ijoin" "img2pdf" "import" "imv" "inc" "includeres" "incus" "inetadm" "influx" "info" "infocmp" "initctl" "initdb" "inject" "inkscape" "inotifywait" "inotifywatch" "inshellisense" "insmod" "install" "install-info" "installpkg" "interdiff" "invoke-rc.d" "ion" "ionice" "iostat" "ip" "ip6tables" "ip6tables-restore" "ip6tables-save" "ipadm" "ipcalc" "ipcmk" "ipcrm" "ipcs" "iperf" "iperf3" "ipfw" "ipkg" "ipmitool" "ipsec" "ipset" "iptables" "iptables-restore" "iptables-save" "ipv6calc" "irb" "iredis" "ironic" "irssi" "isag" "iscsiadm" "isort" "ispell" "isql" "iwconfig" "iwlist" "iwpriv" "iwspy" "jadetex" "jail" "jar" "jarsigner" "java" "javac" "javadoc" "javah" "javap" "javaws" "jdb" "jexec" "jj" "jls" "joe" "join" "jot" "journalctl" "jpegoptim" "jps" "jq" "jshint" "json_xs" "jsonschema" "julia" "just" "k3b" "k3sup" "k6" "k9s" "kak" "kak-lsp" "kcl" "kcov" "kdeconnect-cli" "kdump" "kernel-install" "keystone" "keytool" "kfmclient" "kill" "killall" "killall5" "kioclient" "kiro" "kitten" "kitty" "kldload" "kldunload" "kmod" "kmonad" "knock" "koji" "kompose" "konqueror" "kotlin" "kotlinc" "kpartx" "kpdf" "kplayer" "ksh" "ksh88" "ksh93" "ktlint" "ktrace" "ktutil" "kubeadm" "kubebuilder" "kubectl" "kubeseal" "kustomize" "kvno" "l2ping" "larch" "last" "lastb" "lastlog" "latex" "latexmk" "lazygit" "lbzip2" "ldap" "ldapadd" "ldapcompare" "ldapdelete" "ldapmodify" "ldapmodrdn" "ldappasswd" "ldapsearch" "ldapvi" "ldapwhoami" "ldconfig" "ldconfig.real" "ldd" "lefthook" "less" "lf" "lftp" "lftpget" "lha" "libreoffice" "light" "lightdm" "lighty-disable-mod" "lighty-enable-mod" "lilo" "limactl" "link" "links" "links2" "lintian" "lintian-info" "linux" "lisp" "list_admins" "list_lists" "list_members" "list_owners" "litecli" "lldb" "llvm-g++" "llvm-gcc" "llvm-objdump" "llvm-otool" "ln" "lnav" "lncrawl" "loadkeys" "locale" "locale-gen" "localectl" "localedef" "localsearch" "locate" "logger" "loginctl" "logname" "look" "losetup" "lp" "lpadmin" "lpinfo" "lpoptions" "lpq" "lpr" "lprm" "lpstat" "lrzip" "ls" "lsattr" "lsb_release" "lsblk" "lscfg" "lsclocks" "lscpu" "lsdev" "lsdiff" "lsfd" "lsinitrd" "lsipc" "lsirq" "lslocks" "lslogins" "lslv" "lsmem" "lsmod" "lsns" "lsof" "lspv" "lsscsi" "lsusb" "lsvg" "ltrace" "lua" "lua5.0" "lua5.1" "lua5.2" "lua5.3" "lua5.4" "lua50" "lua51" "lua52" "lua53" "lua54" "luac" "luac5.0" "luac5.1" "luac5.2" "luac5.3" "luac5.4" "luac50" "luac51" "luac52" "luac53" "luac54" "luarocks" "luseradd" "luserdel" "lusermod" "lvchange" "lvcreate" "lvdisplay" "lvextend" "lvm" "lvmdiskscan" "lvreduce" "lvremove" "lvrename" "lvresize" "lvs" "lvscan" "lynx" "lz4" "lz4c" "lz4c32" "lz4cat" "lzcat" "lzip" "lzma" "lzop" "m-a" "mac2unix" "macof" "madison" "magick" "magnum" "mail" "mailmanctl" "mailsnarf" "make" "make-kpkg" "makeinfo" "makepkg" "man" "manage.py" "manila" "mark" "marp" "mat" "mat2" "matlab" "mattrib" "maturin" "mbimcli" "mc" "mcd" "mcomix" "mcookie" "mcopy" "mcrypt" "md2" "md4" "md5" "md5sum" "mdadm" "mdbook" "mdecrypt" "mdel" "mdeltree" "mdfind" "mdir" "mdls" "mdtool" "mdu" "mdutil" "medusa" "meld" "melt" "members" "mencal" "mencoder" "mere" "merge" "mergechanges" "metaflac" "mfiutil" "mformat" "mgv" "mhfixmsg" "mhlist" "mhmail" "mhn" "mhparam" "mhpath" "mhshow" "mhstore" "micro" "micropython" "mii-diag" "mii-tool" "minicom" "minikube" "mistral" "mitmproxy" "mix" "mixerctl" "mkcert" "mkdir" "mkfifo" "mkfs" "mkinitrd" "mkisofs" "mknod" "mksh" "mkshortcut" "mkshortcut.exe" "mkswap" "mktemp" "mktunes" "mkzsh" "mkzsh.exe" "mlabel" "mlocate" "mmcli" "mmd" "mmm" "mmount" "mmove" "mmsitepass" "modinfo" "modprobe" "module" "module-assistant" "mogrify" "mokutil" "molecule" "monasca" "mondoarchive" "monodevelop" "montage" "moosic" "more" "mosh" "mount" "mountpoint" "mousepad" "mozilla" "mozilla-firefox" "mozilla-xremote-client" "mpc" "mplayer" "mplayer2" "mpstat" "mpv" "mr" "mrd" "mread" "mren" "mrsasutil" "msgchk" "msgsnarf" "msynctool" "mt" "mtn" "mtoolstest" "mtr" "mtx" "mtype" "munchlist" "munin-node-configure" "munin-run" "munin-update" "munindoc" "mupdf" "murano" "mush" "mussh" "mutt" "muttng" "mv" "mvim" "mvn" "mx" "mycli" "mypy" "mysql" "mysqladmin" "mysqldiff" "mysqldump" "mysqlimport" "mysqlshow" "n-m3u8dl-re" "namei" "nano" "native2ascii" "nautilus" "nawk" "nc" "ncal" "ncdu" "ncftp" "nedit" "neomutt" "nerdctl" "netcat" "nethogs" "netplan" "netrik" "netscape" "netstat" "networkctl" "networksetup" "neutron" "new" "newgrp" "newlist" "newman" "newrelic" "newusers" "next" "nfpm" "ng" "nginx" "ngrep" "nh" "nice" "nilaway" "nix" "nix-build" "nix-channel" "nix-instantiate" "nix-shell" "nixos-rebuild" "nkf" "nl" "nm" "nmap" "nmblookup" "nmcli" "nocorrect" "node" "nohup" "nomad" "nova" "nox" "npm" "nproc" "ns" "nsenter" "nslookup" "nsupdate" "ntalk" "ntpd" "ntpdate" "nu" "numfmt" "nvim" "nvram" "objdump" "od" "odme" "odmget" "odmshow" "ogg123" "oggdec" "oggenc" "ogginfo" "oh-my-posh" "oksh" "okular" "ollama" "oomctl" "op" "open" "openscad" "openssl" "openstack" "openvpn" "opera" "opera-next" "opkg" "optipng" "opusdec" "opusenc" "opusinfo" "orbctl" "osascript" "osc" "otool" "p4" "p4d" "pack" "pack200" "packer" "packf" "pacman" "pacman-conf" "pacman-db-upgrade" "pacman-key" "pacman-mirrors" "palemoon" "pamac" "pandoc" "parsehdlist" "partx" "paru" "pass" "passwd" "paste" "patch" "pathchk" "patool" "pax" "pbcopy" "pbpaste" "pbuilder" "pbzip2" "pccardctl" "pcmanfm" "pcp-htop" "pcred" "pdf2dsc" "pdf2ps" "pdfattach" "pdfdetach" "pdffonts" "pdfimages" "pdfinfo" "pdfjadetex" "pdflatex" "pdfopt" "pdfseparate" "pdfsig" "pdftex" "pdftexi2dvi" "pdftk" "pdftocairo" "pdftohtml" "pdftopbm" "pdftoppm" "pdftops" "pdftotext" "pdfunite" "pdksh" "pdlzip" "perf" "perl" "perlcritic" "perldoc" "perltidy" "pfctl" "pfexec" "pfiles" "pflags" "pg_config" "pg_ctl" "pg_dump" "pg_dumpall" "pg_isready" "pg_restore" "pg_upgrade" "pgcli" "pgrep" "phing" "php" "phpstorm" "picard" "pick" "picocom" "pidof" "pidstat" "pidwait" "pigz" "pine" "pinef" "pinfo" "ping" "ping4" "ping6" "pinky" "pip" "pipenv" "pipx" "piuparts" "pixi" "pkg" "pkg-config" "pkg-get" "pkg_add" "pkg_create" "pkg_delete" "pkg_info" "pkgadd" "pkgcli" "pkgconf" "pkgin" "pkginfo" "pkgrm" "pkgsite" "pkgtool" "pkill" "plague-client" "pldd" "plutil" "plzip" "pm-hibernate" "pm-is-supported" "pm-powersave" "pm-suspend" "pm-suspend-hybrid" "pmake" "pman" "pmap" "pmcat" "pmdesc" "pmeth" "pmexp" "pmfunc" "pmload" "pmls" "pmpath" "pmvers" "pngcheck" "pngfix" "pnpm" "podgrep" "podman" "podpath" "podtoc" "poff" "policytool" "pon" "portaudit" "portlint" "portmaster" "portsnap" "postalias" "postcat" "postconf" "postfix" "postgres" "postmap" "postmaster" "postqueue" "postsuper" "povray" "powerd" "poweroff" "powerprofilesctl" "powertop" "ppc-koji" "pprof" "pr" "prelink" "present" "prettybat" "prettyping" "prev" "printenv" "prlimit" "pro" "procs" "procstat" "prompt" "protoc" "prove" "prs" "prstat" "prt" "prun" "ps" "ps2ascii" "ps2epsi" "ps2pdf" "ps2pdf12" "ps2pdf13" "ps2pdf14" "ps2pdfwr" "ps2ps" "psbook" "pscale" "pscp" "pscp.exe" "psed" "psig" "psmerge" "psmulti" "psnup" "psql" "psresize" "psselect" "pstack" "pstoedit" "pstop" "pstops" "pstotgif" "pswrap" "ptree" "ptx" "pulumi" "pump" "puppet" "puppetca" "puppetd" "puppetdoc" "puppetmasterd" "puppetqd" "puppetrun" "putclip" "putclip.exe" "pv" "pvchange" "pvcreate" "pvdisplay" "pvmove" "pvremove" "pvs" "pvscan" "pwait" "pwck" "pwd" "pwdx" "pwgen" "pxz" "py.test" "py.test-2" "py.test-3" "pycharm" "pycodestyle" "pydoc" "pydoc3" "pydocstyle" "pyflakes" "pygmentize" "pyhtmlizer" "pylint" "pylint-2" "pylint-3" "pypy" "pypy3" "pyston" "pyston3" "pytest" "pytest-2" "pytest-3" "python" "python2" "python2.7" "python3" "python3.10" "python3.11" "python3.12" "python3.13" "python3.3" "python3.4" "python3.5" "python3.6" "python3.7" "python3.8" "python3.9" "pyvenv" "pyvenv-3.10" "pyvenv-3.11" "pyvenv-3.12" "pyvenv-3.13" "pyvenv-3.4" "pyvenv-3.5" "pyvenv-3.6" "pyvenv-3.7" "pyvenv-3.8" "pyvenv-3.9" "qdbus" "qemu" "qemu-kvm" "qemu-system-i386" "qemu-system-x86_64" "qiv" "qmicli" "qmk" "qpdf" "qrencode" "qrunner" "qtplay" "querybts" "quilt" "quota" "quotacheck" "quotaoff" "quotaon" "qutebrowser" "radvdump" "rails" "rake" "ralsh" "ramalama" "ranger" "ranlib" "rar" "rc" "rcctl" "rclone" "rcp" "rcs" "rcsdiff" "rdesktop" "rdict" "readelf" "readlink" "readprofile" "readshortcut" "readshortcut.exe" "reboot" "rebootin" "redis-cli" "refile" "reindexdb" "reload" "remove_members" "removepkg" "rename" "renice" "repl" "reportbug" "repquota" "reprepro" "resolvconf" "resolvectl" "restart" "restic" "resume-cli" "retawq" "reuse" "rev" "rfcomm" "rfkill" "rg" "rgrep" "rgview" "rgvim" "ri" "rider" "rifle" "ripsecrets" "rlog" "rlogin" "rm" "rmadison" "rmd160" "rmdel" "rmdir" "rmf" "rmic" "rmid" "rmiregistry" "rmlist" "rmm" "rmmod" "route" "rpcdebug" "rpm" "rpm2targz" "rpm2tgz" "rpm2txz" "rpmbuild" "rpmbuild-md5" "rpmcheck" "rpmkeys" "rpmquery" "rpmsign" "rpmspec" "rpmverify" "rrdtool" "rsh" "rsync" "rtcwake" "rtin" "rubber" "rubber-info" "rubber-pipe" "ruby" "ruby-mri" "rubymine" "run-help" "run0" "runuser" "rup" "rusage" "rust-analyzer" "rust-arch" "rust-b2sum" "rust-base32" "rust-base64" "rust-basename" "rust-basenc" "rust-cat" "rust-chcon" "rust-chgrp" "rust-chmod" "rust-chown" "rust-chroot" "rust-cksum" "rust-comm" "rust-coreutils" "rust-cp" "rust-csplit" "rust-cut" "rust-date" "rust-dd" "rust-df" "rust-dir" "rust-dircolors" "rust-dirname" "rust-du" "rust-echo" "rust-env" "rust-expand" "rust-expr" "rust-factor" "rust-false" "rust-fmt" "rust-fold" "rust-groups" "rust-head" "rust-hostid" "rust-hostname" "rust-id" "rust-install" "rust-join" "rust-kill" "rust-link" "rust-ln" "rust-logname" "rust-ls" "rust-md5sum" "rust-mkdir" "rust-mkfifo" "rust-mknod" "rust-mktemp" "rust-more" "rust-mv" "rust-nice" "rust-nl" "rust-nohup" "rust-nproc" "rust-numfmt" "rust-od" "rust-paste" "rust-pathchk" "rust-pinky" "rust-pr" "rust-printenv" "rust-printf" "rust-ptx" "rust-pwd" "rust-readlink" "rust-realpath" "rust-rm" "rust-rmdir" "rust-runcon" "rust-seq" "rust-sha1sum" "rust-sha224sum" "rust-sha256sum" "rust-sha384sum" "rust-sha512sum" "rust-shred" "rust-shuf" "rust-sleep" "rust-sort" "rust-split" "rust-stat" "rust-stdbuf" "rust-stty" "rust-sum" "rust-sync" "rust-tac" "rust-tail" "rust-tee" "rust-test" "rust-timeout" "rust-touch" "rust-tr" "rust-true" "rust-truncate" "rust-tsort" "rust-tty" "rust-uname" "rust-unexpand" "rust-uniq" "rust-unlink" "rust-uptime" "rust-users" "rust-vdir" "rust-wc" "rust-who" "rust-whoami" "rust-yes" "rustc" "rustdoc" "rustrover" "rustup" "rview" "rvim" "rwho" "rxvt" "s2p" "s390-koji" "sact" "sadf" "sahara" "sar" "savecore" "saw" "say" "sbcl" "sbcl-mt" "sbopkg" "sbuild" "sc_usage" "scan" "scc" "sccs" "sccsdiff" "schedtool" "schroot" "scl" "scons" "scp" "screen" "script" "scriptlive" "scriptreplay" "scrot" "scrub" "scselect" "scutil" "sd" "sdkmanager" "sdptool" "seaf-cli" "sed" "semver" "senlin" "seq" "serialver" "serie" "service" "set-env" "setarch" "setfacl" "setfacl.exe" "setfattr" "setpriv" "setquota" "setsid" "setterm" "setxkbmap" "sfdisk" "sftp" "sh" "sha1" "sha1sum" "sha224sum" "sha256" "sha256sum" "sha384" "sha384sum" "sha512" "sha512sum" "sha512t256" "shasum" "shellcheck" "show" "showchar" "showkey" "showmount" "shred" "shuf" "shutdown" "sidedoor" "signify" "singularity" "sisu" "sitecopy" "skein1024" "skein256" "skein512" "skipstone" "slabtop" "slapt-get" "slapt-src" "sleep" "slides" "slitex" "slocate" "slogin" "slrn" "slsa-verifier" "smartctl" "smbcacls" "smbclient" "smbcontrol" "smbcquotas" "smbget" "smbpasswd" "smbstatus" "smbtar" "smbtree" "smit" "smitty" "snap" "snoop" "snownews" "soa" "socket" "sockstat" "soft" "softwareupdate" "sort" "sortm" "spamassassin" "sparc-koji" "speedtest-cli" "split" "splitdiff" "spovray" "sqlite" "sqlite3" "sqsh" "sr" "srptool" "ss" "ssh" "ssh-add" "ssh-agent" "ssh-copy-id" "ssh-keygen" "ssh-keyscan" "sshfs" "sshmitm" "sshow" "st" "star" "starship" "start" "stat" "staticcheck" "status" "stdbuf" "stg" "stop" "stow" "strace" "strace64" "stream" "strings" "strip" "strongswan" "stty" "su" "subl" "sudo" "sudoedit" "sudoreplay" "sulogin" "sum" "supervisorctl" "supervisord" "surfraw" "sv" "svcadm" "svccfg" "svcprop" "svcs" "svg-term" "svgcleaner" "svk" "svn" "svn-buildpackage" "svnadmin" "sw_vers" "swaks" "swanctl" "swaplabel" "swapoff" "swapon" "sway" "swaybar" "swaybg" "swayidle" "swaylock" "swaymsg" "swaynag" "swift" "swiftc" "syft" "sync" "sync_members" "synclient" "sysbench" "sysclean" "sysctl" "sysmerge" "syspatch" "sysrc" "systat" "system_profiler" "systemctl" "systemd-analyze" "systemd-ask-password" "systemd-cat" "systemd-cgls" "systemd-cgtop" "systemd-confext" "systemd-creds" "systemd-cryptenroll" "systemd-delta" "systemd-detect-virt" "systemd-dissect" "systemd-id128" "systemd-inhibit" "systemd-machine-id-setup" "systemd-notify" "systemd-path" "systemd-resolve" "systemd-run" "systemd-sysext" "systemd-tmpfiles" "systemd-tty-ask-password-agent" "systemd-vpick" "sysupgrade" "tac" "tacker" "tail" "talk" "talosctl" "taplo" "tar" "tardy" "task" "taskset" "tc" "tcp_open" "tcpdump" "tcpkill" "tcpnice" "tcptraceroute" "tcsh" "tda" "tdd" "tde" "tdr" "tea" "tee" "telnet" "templ" "termux-apt-repo" "terraform" "terraform-ls" "terragrunt" "terramate" "tesseract" "tex" "texi2any" "texi2dvi" "texi2pdf" "texindex" "tg" "tidy" "tig" "tightvncviewer" "time" "timedatectl" "timeout" "tin" "tinygo" "tinysparql" "tipc" "tkconch" "tkinfo" "tla" "tldr" "tload" "tmate" "tmux" "todo" "todo.sh" "tofu" "toilet" "toit.lsp" "toit.pkg" "toolbox" "top" "tor-browser" "tor-gencert" "tor-print-ed-signing-cert" "tor-resolve" "torsocks" "totdconfig" "touch" "tox" "tpb" "tpkg-debarch" "tpkg-install" "tpkg-install-libc" "tpkg-make" "tpkg-update" "tput" "tqdm" "tr" "trace-cmd" "tracepath" "tracepath6" "traceroute" "traefik" "transmission-cli" "transmission-create" "transmission-daemon" "transmission-edit" "transmission-remote" "transmission-show" "trash" "tree" "trial" "trivy" "trove" "truncate" "truss" "tryaffix" "ts" "tsc" "tsh" "tshark" "tsig-keygen" "tsort" "tty" "ttyd" "tunctl" "tune2fs" "tunes2pod" "turbo" "twidge" "twist" "twistd" "txt" "typst" "ua" "ubuntu-bug" "ubuntu-insights" "ubuntu-report" "uclampset" "udevadm" "udisksctl" "ufw" "ul" "uml_mconsole" "uml_moo" "uml_switch" "umount" "unace" "uname" "unbrotli" "uncompress" "unexpand" "unget" "uniq" "unison" "units" "unix2dos" "unix2mac" "unlink" "unlz4" "unlzma" "unpack" "unpack200" "unpigz" "unrar" "unset-env" "unshare" "unshunt" "unwrapdiff" "unxz" "unzip" "update-alternatives" "update-initramfs" "update-java-alternatives" "update-rc.d" "upgradepkg" "upower" "uptime" "upx" "urlsnarf" "urpme" "urpmf" "urpmi" "urpmi.addmedia" "urpmi.removemedia" "urpmi.update" "urpmq" "urxvt" "urxvt256c" "urxvt256c-ml" "urxvt256c-mlc" "urxvt256cc" "urxvtc" "usbconfig" "uscan" "useradd" "userdbctl" "userdel" "usermod" "users" "uuidd" "uuidgen" "uuidparse" "vacuumdb" "vagrant" "val" "valgrind" "varlinkctl" "vault" "vcs_info_hookadd" "vcs_info_hookdel" "vdir" "vercel" "vgcfgbackup" "vgcfgrestore" "vgchange" "vgck" "vgconvert" "vgcreate" "vgdisplay" "vgexport" "vgextend" "vgimport" "vgmerge" "vgmknodes" "vgreduce" "vgremove" "vgrename" "vgs" "vgscan" "vgsplit" "vhs" "vi" "view" "viewnior" "vigr" "vim" "vim-addons" "vimdiff" "vipw" "virsh" "virt-admin" "virt-host-validate" "virt-pki-validate" "virt-xml-validate" "visudo" "vitrage" "viu" "vivid" "vlc" "vmctl" "vmstat" "vncserver" "vncviewer" "volta" "vorbiscomment" "vpnc" "vpnc-connect" "vserver" "vunnel" "w" "w3m" "wajig" "wall" "wanna-build" "watch" "watcher" "watchexec" "watchgnupg" "waypoint" "wc" "webmitm" "webstorm" "wezterm" "wget" "what" "whatis" "whereis" "which" "whiptail" "who" "whoami" "whois" "whom" "wiggle" "wine" "wine-development" "wine-stable" "wine64" "wine64-development" "wine64-stable" "wineboot" "winepath" "wineserver" "winetricks" "wipefs" "wire" "wireshark" "wishlist" "withlist" "wl-copy" "wl-mirror" "wl-paste" "wodim" "woeusb" "wol" "wpa_cli" "wpctl" "write" "wsimport" "wt" "wtf" "wvdial" "www" "xargs" "xattr" "xauth" "xautolock" "xbacklight" "xbps-alternatives" "xbps-checkvers" "xbps-create" "xbps-dgraph" "xbps-digest" "xbps-fbulk" "xbps-fetch" "xbps-install" "xbps-pkgdb" "xbps-query" "xbps-reconfigure" "xbps-remove" "xbps-rindex" "xbps-uchroot" "xbps-uhelper" "xbps-uunshare" "xclip" "xcode-select" "xdg-mime" "xdg-settings" "xdotool" "xdpyinfo" "xdvi" "xev" "xfd" "xfig" "xfontsel" "xfreerdp" "xgamma" "xh" "xhost" "xinput" "xkill" "xli" "xloadimage" "xlsatoms" "xlsclients" "xml" "xmllint" "xmlstarlet" "xmlwf" "xmms" "xmms2" "xmodmap" "xmosaic" "xon" "xonsh" "xournal" "xpdf" "xping" "xpovray" "xprop" "xrandr" "xrdb" "xscreensaver-command" "xset" "xsetbg" "xsetroot" "xsltproc" "xterm" "xtightvncviewer" "xtp" "xv" "xvfb-run" "xview" "xvnc4viewer" "xvncviewer" "xwd" "xwininfo" "xwit" "xwud" "xxd" "xxhsum" "xz" "xzcat" "xzdec" "yafc" "yarn" "yash" "yast" "yast2" "yay" "yes" "yj" "ykman" "youtube-dl" "ypbind" "ypcat" "ypmatch" "yppasswd" "yppoll" "yppush" "ypserv" "ypset" "ypwhich" "ypxfr" "yt-dlp" "ytalk" "yum" "yum-arch" "yumdb" "zargs" "zathura" "zcalc" "zcat" "zcp" "zdb" "zdelattr" "zdump" "zeal" "zed" "zegrep" "zen" "zf_chmod" "zf_ln" "zf_mkdir" "zf_mv" "zf_rm" "zf_rmdir" "zfgrep" "zfs" "zgetattr" "zgrep" "zig" "zip" "zipinfo" "zlistattr" "zln" "zlogin" "zmail" "zmv" "zone" "zoneadm" "zopfli" "zopflipng" "zoxide" "zpool" "zpty" "zramctl" "zsetattr" "zsh" "zsh-mime-handler" "zsocket" "ztodo" "zun" "zxpdf" "zypper"


# --- starship init ---
# ZSH has a quirk where `preexec` is only run if a command is actually run (i.e
# pressing ENTER at an empty command line will not cause preexec to fire). This
# can cause timing issues, as a user who presses "ENTER" without running a command
# will see the time to the start of the last command, which may be very large.

# To fix this, we create STARSHIP_START_TIME upon preexec() firing, and destroy it
# after drawing the prompt. This ensures that the timing for one command is only
# ever drawn once (for the prompt immediately after it is run).

zmodload zsh/parameter  # Needed to access jobstates variable for STARSHIP_JOBS_COUNT

# Defines a function `__starship_get_time` that sets the time since epoch in millis in STARSHIP_CAPTURED_TIME.
if [[ $ZSH_VERSION == ([1-4]*) ]]; then
    # ZSH <= 5; Does not have a built-in variable so we will rely on Starship's inbuilt time function.
    __starship_get_time() {
        STARSHIP_CAPTURED_TIME=$(/usr/local/bin/starship time)
    }
else
    zmodload zsh/datetime
    zmodload zsh/mathfunc
    __starship_get_time() {
        (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
    }
fi

# The two functions below follow the naming convention `prompt_<theme>_<hook>`
# for compatibility with Zsh's prompt system. See
# https://github.com/zsh-users/zsh/blob/2876c25a28b8052d6683027998cc118fc9b50157/Functions/Prompts/promptinit#L155

# Runs before each new command line.
prompt_starship_precmd() {
    # Save the status, because subsequent commands in this function will change $?
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]})

    # Calculate duration if a command was executed
    if (( ${+STARSHIP_START_TIME} )); then
        # If an arithmetic expression evaluates to 0, its exit status is 1:
        # "The return status is 0 if the arithmetic value of the expression is non-zero, 1 if it is zero, and 2 if an error occurred."
        # In rare cases, the subtraction below can result in an int 0 result (yes, really),
        # which would then kill the shell if 'set -e' is in effect.
        # We therefore have to assign the result outside the expression (using 'STARSHIP_DURATION=$((...))'),
        # because unlike '(())', '$(())' gets a return status of 0 even if the expression evaluates to int 0
        # (but it still surfaces a potential error, normally status 2, as status 1).
        __starship_get_time && STARSHIP_DURATION=$(( STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
        unset STARSHIP_START_TIME
    # Drop status and duration otherwise
    else
        unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi

    # Use length of jobstates array as number of jobs. Expansion fails inside
    # quotes so we set it here and then use the value later on.
    STARSHIP_JOBS_COUNT="${#jobstates[*]}"
}

# Runs after the user submits the command line, but before it is executed and
# only if there's an actual command to run
prompt_starship_preexec() {
    __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hook functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt if the user switches vi modes
starship_zle-keymap-select() {
    zle reset-prompt
}

## Check for existing keymap-select widget.
if [[ -v widgets[zle-keymap-select] ]]; then
    # zle-keymap-select is a special widget so it'll be "user:fnName" or nothing. Let's get fnName only.
    __starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
fi

if [[ -z ${__starship_preserved_zle_keymap_select:-} ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select;
else
    # Define a wrapper fn to call the original widget fn and then Starship's.
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@";
        starship_zle-keymap-select "$@";
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped;
fi

export STARSHIP_SHELL="zsh"

# Set up the session key that will be used to store logs
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"; # Random generates a number b/w 0 - 32767
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000" # Pad it to 16+ chars.
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}; # Trim to 16-digits if excess.

VIRTUAL_ENV_DISABLE_PROMPT=1

setopt promptsubst

PROMPT='$('/usr/local/bin/starship' prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
RPROMPT='$('/usr/local/bin/starship' prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
PROMPT2="$(/usr/local/bin/starship prompt --continuation)"

