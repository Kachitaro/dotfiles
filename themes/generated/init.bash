# Auto-generated Bash init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

# --- atuin init ---
# Include guard
if [[ ${__atuin_initialized-} == true ]]; then
    false
elif [[ $- != *i* ]]; then
    # Enable only in interactive shells
    false
elif ((BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] < 1)); then
    # Require bash >= 3.1
    [[ -t 2 ]] && printf 'atuin: requires bash >= 3.1 for the integration.\n' >&2
    false
else
    true
fi && {
# Set ATUIN_NO_BUILTIN_PREEXEC=1 to disable loading bash-preexec
__atuin_load_builtin_preexec() {
    # bash-preexec.sh -- Bash support for ZSH-like 'preexec' and 'precmd' functions.
    # https://github.com/rcaloras/bash-preexec
    #
    #
    # 'preexec' functions are executed before each interactive command is
    # executed, with the interactive command as its argument. The 'precmd'
    # function is executed before each prompt is displayed.
    #
    # Author: Ryan Caloras (ryan@bashhub.com)
    # Forked from Original Author: Glyph Lefkowitz
    #
    # V0.6.0
    #
    
    # General Usage:
    #
    #  1. Source this file at the end of your bash profile so as not to interfere
    #     with anything else that's using PROMPT_COMMAND.
    #
    #  2. Add any precmd or preexec functions by appending them to their arrays:
    #       e.g.
    #       precmd_functions+=(my_precmd_function)
    #       precmd_functions+=(some_other_precmd_function)
    #
    #       preexec_functions+=(my_preexec_function)
    #
    #  3. Consider changing anything using the DEBUG trap or PROMPT_COMMAND
    #     to use preexec and precmd instead. Preexisting usages will be
    #     preserved, but doing so manually may be less surprising.
    #
    #  Note: This module requires two Bash features which you must not otherwise be
    #  using: the "DEBUG" trap, and the "PROMPT_COMMAND" variable. If you override
    #  either of these after bash-preexec has been installed it will most likely break.
    
    # Tell shellcheck what kind of file this is.
    # shellcheck shell=bash
    
    # Make sure this is bash that's running and return otherwise.
    # Use POSIX syntax for this line:
    if [ -z "${BASH_VERSION-}" ]; then
        return 1
    fi
    
    # We only support Bash 3.1+.
    # Note: BASH_VERSINFO is first available in Bash-2.0.
    if [[ -z "${BASH_VERSINFO-}" ]] || (( BASH_VERSINFO[0] < 3 || (BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] < 1) )); then
        return 1
    fi
    
    # Avoid duplicate inclusion
    if [[ -n "${bash_preexec_imported:-}" || -n "${__bp_imported:-}" ]]; then
        return 0
    fi
    bash_preexec_imported="defined"
    
    # WARNING: This variable is no longer used and should not be relied upon.
    # Use ${bash_preexec_imported} instead.
    # shellcheck disable=SC2034
    __bp_imported="${bash_preexec_imported}"
    
    # Should be available to each precmd and preexec
    # functions, should they want it. $? and $_ are available as $? and $_, but
    # $PIPESTATUS is available only in a copy, $BP_PIPESTATUS.
    # TODO: Figure out how to restore PIPESTATUS before each precmd or preexec
    # function.
    __bp_last_ret_value="$?"
    BP_PIPESTATUS=("${PIPESTATUS[@]}")
    __bp_last_argument_prev_command="$_"
    
    __bp_inside_precmd=0
    __bp_inside_preexec=0
    
    # Initial PROMPT_COMMAND string that is removed from PROMPT_COMMAND post __bp_install
    # shellcheck disable=SC2016
    __bp_install_string='__bp_install "$_"'
    
    # Fails if any of the given variables are readonly
    # Reference https://stackoverflow.com/a/4441178
    __bp_require_not_readonly() {
        local var
        for var; do
            if ! ( unset "$var" 2> /dev/null ); then
                echo "bash-preexec requires write access to ${var}" >&2
                return 1
            fi
        done
    }
    
    # Remove ignorespace and or replace ignoreboth from HISTCONTROL
    # so we can accurately invoke preexec with a command from our
    # history even if it starts with a space.
    __bp_adjust_histcontrol() {
        local histcontrol
        histcontrol="${HISTCONTROL:-}"
        histcontrol="${histcontrol//ignorespace}"
        # Replace ignoreboth with ignoredups
        if [[ "$histcontrol" == *"ignoreboth"* ]]; then
            histcontrol="ignoredups:${histcontrol//ignoreboth}"
        fi
        export HISTCONTROL="$histcontrol"
    }
    
    # This variable describes whether we are currently in "interactive mode";
    # i.e. whether this shell has just executed a prompt and is waiting for user
    # input.  It documents whether the current command invoked by the trace hook is
    # run interactively by the user; it's set immediately after the prompt hook,
    # and unset as soon as the trace hook is run.
    __bp_preexec_interactive_mode=""
    
    # These global arrays are used to add functions to be run before, or after,
    # prompts.  Note that Bash < 4.2 does not have the "-g" option of the "declare"
    # builtin.  We actually do not need to explicitly initialize these arrays.
    #declare -ga precmd_functions
    #declare -ga preexec_functions
    
    # Trims leading and trailing whitespace from $2 and writes it to the variable
    # name passed as $1
    __bp_trim_whitespace() {
        local var=${1:?} text=${2:-}
        text="${text#"${text%%[![:space:]]*}"}"   # remove leading whitespace characters
        text="${text%"${text##*[![:space:]]}"}"   # remove trailing whitespace characters
        printf -v "$var" '%s' "$text"
    }
    
    
    # Trims whitespace and removes any leading or trailing semicolons from $2 and
    # writes the resulting string to the variable name passed as $1. This also
    # removes the no-op colons, which are converted from the hooks to remove. Used
    # for manipulating substrings in PROMPT_COMMAND
    __bp_sanitize_string() {
        local var=${1:?} sanitized=${2:-}
    
        local unset_extglob=
        if ! shopt -q extglob; then
            unset_extglob=yes
            shopt -s extglob
        fi
    
        # We specify newline character through the variable `nl' because $'\n'
        # inside "${var//...}" is treated literally as "\$'\\n'" when `extquote' is
        # unset (shopt -u extquote). (Note: Bash 5.2's extquote seems to be buggy.)
        local tmp nl=$'\n'
        while
            # Note: Quoting parameter expansions $nl in PAT of ${var//PAT/REP} is
            # required by shellcheck.  On the other hand, we should not quote the
            # parameter expansions $nl in REP because the quotes will remain in the
            # replaced result with `shopt -s compat42'.
            # Note: We use ?(+([[:blank:]])) instead of *([[:blank:]]) to work
            # around a bug of Bash 3.2 that *(...) is not properly processed as
            # extglob at the beginning of the pattern in ${var//pat/rep}.
            tmp="${sanitized//?(+([[:blank:]]))[";$nl"]*([[:blank:]]):*([[:blank:]])[";$nl"]*([[:blank:]])/$nl}"
            [[ "$tmp" != "$sanitized" ]]
        do
            sanitized="$tmp"
        done
        sanitized="${sanitized#:*([[:blank:]])[";$nl"]}"
        sanitized="${sanitized%[";$nl"]*([[:blank:]]):}"
        __bp_trim_whitespace sanitized "$sanitized"
        sanitized=${sanitized%;}
        sanitized=${sanitized#;}
        __bp_trim_whitespace sanitized "$sanitized"
        if [[ "$sanitized" == ":" ]]; then
            sanitized=
        fi
        printf -v "$var" '%s' "$sanitized"
    
        if [[ -n "$unset_extglob" ]]; then
            shopt -u extglob
        fi
    }
    
    
    # Bash >= 5.1 supports the array version of PROMPT_COMMAND.
    __bp_use_array_prompt_command() {
        (( BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 1) ))
    }
    
    
    # Remove $1 and sanitize each elements of PROMPT_COMMAND. We want to keep
    # PROMPT_COMMAND scalar in bash < 5.1 because some configuration tests the
    # support for the array PROMPT_COMMAND by checking the array attribute of
    # PROMPT_COMMAND.
    __bp_remove_command_from_prompt_command() {
        local removed_command="${1-}"
        if __bp_use_array_prompt_command; then
            local i sanitized_prompt_command
            for i in "${!PROMPT_COMMAND[@]}"; do
                sanitized_prompt_command="${PROMPT_COMMAND[i]:-}"
                sanitized_prompt_command="${sanitized_prompt_command//"$removed_command"/:}"
                __bp_sanitize_string sanitized_prompt_command "$sanitized_prompt_command"
                if [[ -n "$sanitized_prompt_command" ]]; then
                    PROMPT_COMMAND[i]="$sanitized_prompt_command"
                else
                    unset -v 'PROMPT_COMMAND[i]'
                fi
            done
        else
            local sanitized_prompt_command="${PROMPT_COMMAND:-}"
            sanitized_prompt_command="${sanitized_prompt_command//"$removed_command"/:}" # no-op
            __bp_sanitize_string PROMPT_COMMAND "$sanitized_prompt_command"
        fi
    }
    
    
    # This function is installed as part of the PROMPT_COMMAND;
    # It sets a variable to indicate that the prompt was just displayed,
    # to allow the DEBUG trap to know that the next command is likely interactive.
    __bp_interactive_mode() {
        if [[ "${1-}" != "force" && ! "${BATS_VERSION-}" ]] && (( ${#FUNCNAME[*]} > 1 )); then
            # When this function is not called from the top level, the current
            # function call is probably performed via PROMPT_COMMAND saved by
            # another framework (e.g., starship). In this case, we do not want to
            # turn on the "interactive mode" here.
            return 0
        fi
    
        __bp_preexec_interactive_mode="on"
    }
    
    
    # This function is installed as part of the PROMPT_COMMAND.
    # It will invoke any functions defined in the precmd_functions array.
    __bp_precmd_invoke_cmd() {
        # Save the returned value and the last argument from our last command, and
        # the returned value from each process in its pipeline. Note: this MUST be
        # the first thing done in this function.
        # BP_PIPESTATUS may be unused, ignore
        # shellcheck disable=SC2034
        __bp_last_ret_value="$?" __bp_last_argument_prev_command="$_" \
            BP_PIPESTATUS=("${PIPESTATUS[@]}")
    
    
        # Don't invoke precmds if we are inside an execution of an "original
        # prompt command" by another precmd execution loop. This avoids infinite
        # recursion.
        if (( __bp_inside_precmd > 0 )); then
            return "$__bp_last_ret_value"
        fi
    
        # Check and adjust PROMPT_COMMAND to make sure that PROMPT_COMMAND has the
        # form "__bp_precmd_invoke_cmd; ...; __bp_interactive_mode"
        if ! __bp_install_prompt_command; then
            if [[ "${1-}" != "force" && ! "${BATS_VERSION-}" ]] && (( ${#FUNCNAME[*]} > 1 )); then
                # When PROMPT_COMMAND is already properly set up but this function
                # is not called from the top level, the current function call is
                # probably performed via PROMPT_COMMAND saved by another framework
                # (e.g., starship). In this case, we do not need to invoke precmd
                # because it is supposed to be already processed by the top-level
                # __bp_precmd_invoke_cmd.
                return "$__bp_last_ret_value"
            fi
        fi
    
        local __bp_inside_precmd=1
        __bp_invoke_precmd_functions "$__bp_last_ret_value" "$__bp_last_argument_prev_command"
    
        __bp_set_ret_value "$__bp_last_ret_value" "$__bp_last_argument_prev_command"
    }
    
    # This function invokes every function defined in the "precmd_functions" array.
    # This function receives the arguments $1 and $2 for $?  and $_, respectively,
    # which will be set for each precmd function. This function returns the last
    # non-zero exit status of the hook functions. If there is no error, this
    # function returns 0.
    __bp_invoke_precmd_functions() {
        local lastexit=$1 lastarg=$2
        # Invoke every function defined in our function array.
        local precmd_function
        local precmd_function_ret_value
        local precmd_ret_value=0
        for precmd_function in "${precmd_functions[@]}"; do
    
            # Only execute this function if it actually exists.
            # Test existence of functions with: declare -[Ff]
            if type -t "$precmd_function" 1>/dev/null; then
                __bp_set_ret_value "$lastexit" "$lastarg"
                # Quote our function invocation to prevent issues with IFS
                "$precmd_function"
                precmd_function_ret_value=$?
                if [[ "$precmd_function_ret_value" != 0 ]]; then
                    precmd_ret_value="$precmd_function_ret_value"
                fi
            fi
        done
    
        __bp_set_ret_value "$precmd_ret_value"
    }
    
    # Sets a return value in $?. We may want to get access to the $? variable in our
    # precmd functions. This is available for instance in zsh. We can simulate it in bash
    # by setting the value here.
    __bp_set_ret_value() {
        return ${1:+"$1"}
    }
    
    __bp_in_prompt_command() {
    
        local prompt_command_array IFS=$'\n;'
        read -rd '' -a prompt_command_array <<< "${PROMPT_COMMAND[*]:-}"
    
        local trimmed_arg
        __bp_trim_whitespace trimmed_arg "${1:-}"
    
        local command trimmed_command
        for command in "${prompt_command_array[@]:-}"; do
            __bp_trim_whitespace trimmed_command "$command"
            if [[ "$trimmed_command" == "$trimmed_arg" ]]; then
                return 0
            fi
        done
    
        return 1
    }
    
    __bp_load_this_command_from_history() {
        this_command=$(LC_ALL=C HISTTIMEFORMAT='' builtin history 1)
        this_command="${this_command#*[[:digit:]][* ] }"
    
        # Sanity check to make sure we have something to invoke our function with.
        [[ -n "$this_command" ]]
    }
    
    # This function is installed as the DEBUG trap.  It is invoked before each
    # interactive prompt display.  Its purpose is to inspect the current
    # environment to attempt to detect if the current command is being invoked
    # interactively, and invoke 'preexec' if so.
    __bp_preexec_invoke_exec() {
        local lastarg=$_
    
        # Don't invoke preexecs if we are inside of another preexec.
        if (( __bp_inside_preexec > 0 )); then
            return
        fi
        local __bp_inside_preexec=1
    
        # Checks if the file descriptor is not standard out (i.e. '1')
        # __bp_delay_install checks if we're in test. Needed for bats to run.
        # Prevents preexec from being invoked for functions in PS1
        if [[ ! -t 1 && -z "${__bp_delay_install:-}" ]]; then
            return
        fi
    
        if [[ -n "${COMP_POINT:-}" || -n "${READLINE_POINT:-}" ]]; then
            # We're in the middle of a completer or a keybinding set up by "bind
            # -x".  This obviously can't be an interactively issued command.
            return
        fi
        if [[ -z "${__bp_preexec_interactive_mode:-}" ]]; then
            # We're doing something related to displaying the prompt.  Let the
            # prompt set the title instead of me.
            return
        else
            # If we're in a subshell, then the prompt won't be re-displayed to put
            # us back into interactive mode, so let's not set the variable back.
            # In other words, if you have a subshell like
            #   (sleep 1; sleep 2)
            # You want to see the 'sleep 2' as a set_command_title as well.
            if [[ 0 -eq "${BASH_SUBSHELL:-}" ]]; then
                __bp_preexec_interactive_mode=""
            fi
        fi
    
        if  __bp_in_prompt_command "${BASH_COMMAND:-}"; then
            # If we're executing something inside our prompt_command then we don't
            # want to call preexec. Bash prior to 3.1 can't detect this at all :/
            __bp_preexec_interactive_mode=""
            return
        fi
    
        # Save the contents of $_ so that it can be restored later on.
        # https://stackoverflow.com/questions/40944532/bash-preserve-in-a-debug-trap#40944702
        __bp_last_argument_prev_command=$lastarg
    
        local this_command
        __bp_load_this_command_from_history || return
    
        __bp_invoke_preexec_functions "${__bp_last_ret_value:-}" "$__bp_last_argument_prev_command" "$this_command"
        local preexec_ret_value=$?
    
        # Restore the last argument of the last executed command, and set the return
        # value of the DEBUG trap to be the return code of the last preexec function
        # to return an error.
        # If `extdebug` is enabled a non-zero return value from any preexec function
        # will cause the user's command not to execute.
        # Run `shopt -s extdebug` to enable
        __bp_set_ret_value "$preexec_ret_value" "$__bp_last_argument_prev_command"
    }
    
    __bp_invoke_preexec_from_ps0() {
        __bp_last_argument_prev_command="${1:-}"
    
        local this_command
        __bp_load_this_command_from_history || return
    
        __bp_invoke_preexec_functions "${__bp_last_ret_value:-}" "$__bp_last_argument_prev_command" "$this_command"
    }
    
    # This function invokes every function defined in the "preexec_functions"
    # array.  This function receives the arguments $1 and $2 for $?  and $_,
    # respectively, which will be set for each preexec function.  The third
    # argument $3 specifies the user command that is going to be executed
    # (corresponding to BASH_COMMAND in the DEBUG trap).  This function returns the
    # last non-zero exit status from the preexec functions.  If there is no error,
    # this function returns `0`.
    __bp_invoke_preexec_functions() {
        local lastexit=$1 lastarg=$2 this_command=$3
        local preexec_function
        local preexec_function_ret_value
        local preexec_ret_value=0
        for preexec_function in "${preexec_functions[@]:-}"; do
    
            # Only execute each function if it actually exists.
            # Test existence of function with: declare -[fF]
            if type -t "$preexec_function" 1>/dev/null; then
                __bp_set_ret_value "$lastexit" "$lastarg"
                # Quote our function invocation to prevent issues with IFS
                "$preexec_function" "$this_command"
                preexec_function_ret_value="$?"
                if [[ "$preexec_function_ret_value" != 0 ]]; then
                    preexec_ret_value="$preexec_function_ret_value"
                fi
            fi
        done
        __bp_set_ret_value "$preexec_ret_value"
    }
    
    __bp_hook_preexec_into_debug() {
        local trap_string
        trap_string=$(trap -p DEBUG)
        trap '__bp_preexec_invoke_exec "$_"' DEBUG
    
        # Preserve any prior DEBUG trap as a preexec function
        eval "local trap_argv=(${trap_string:-})"
        local prior_trap=${trap_argv[2]:-}
        if [[ -n "$prior_trap" ]]; then
            eval '__bp_original_debug_trap() {
                '"$prior_trap"'
            }'
            preexec_functions+=(__bp_original_debug_trap)
        fi
    
        # Adjust our HISTCONTROL Variable if needed.
        __bp_adjust_histcontrol
    
        # Issue #25. Setting debug trap for subshells causes sessions to exit for
        # backgrounded subshell commands (e.g. (pwd)& ). Believe this is a bug in Bash.
        #
        # Disabling this by default. It can be enabled by setting this variable.
        if [[ -n "${__bp_enable_subshells:-}" ]]; then
    
            # Set so debug trap will work be invoked in subshells.
            set -o functrace > /dev/null 2>&1
            shopt -s extdebug > /dev/null 2>&1
        fi
    }
    
    __bp_hook_preexec_into_ps0() {
        # shellcheck disable=SC2016
        PS0=${PS0-}'${ __bp_invoke_preexec_from_ps0 "$_" >&2; }'
    
        # Adjust our HISTCONTROL Variable if needed.
        __bp_adjust_histcontrol
    }
    
    if (( BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3) )); then
        __bp_hook_preexec_proc=__bp_hook_preexec_into_ps0
    else
        __bp_hook_preexec_proc=__bp_hook_preexec_into_debug
    fi
    
    __bp_install() {
        local lastexit=$? lastarg=$_
        # Exit if we already have this installed.
        # shellcheck disable=SC2016
        if [[ "${PROMPT_COMMAND[*]:-}" == *'__bp_precmd_invoke_cmd "$_"'* ]]; then
            return 1
        fi
    
        "$__bp_hook_preexec_proc"
    
        # Remove setting our trap install string and sanitize the existing prompt command string
        __bp_remove_command_from_prompt_command "$__bp_install_string"
    
        __bp_install_prompt_command || true
    
        # Add two functions to our arrays for convenience
        # of definition.
        precmd_functions+=(precmd)
        preexec_functions+=(preexec)
    
        # Invoke our two functions manually that were added to $PROMPT_COMMAND
        __bp_set_ret_value "$lastexit" "$lastarg"
        __bp_precmd_invoke_cmd force
        __bp_interactive_mode force
    }
    
    # Note: We need to add the "trace" attribute to these functions so that "trap
    # ... DEBUG" inside "__bp_install" and "__bp_hook_preexec_into_debug" takes
    # effect even when there is an existing DEBUG trap.
    declare -ft __bp_install __bp_hook_preexec_into_debug
    
    # Encloses PROMPT_COMMAND hooks within __bp_precmd_invoke_cmd and
    # __bp_interactive_mode. If all the PROMPT_COMMAND hooks are already surrounded
    # by __bp_precmd_invoke_cmd and __bp_interactive_mode, the function exits with
    # status 1.
    __bp_install_prompt_command() {
        local prompt_command="${PROMPT_COMMAND:-}"
        if __bp_use_array_prompt_command; then
            local IFS=$'\n'
            prompt_command="${PROMPT_COMMAND[*]:-}"
            IFS=$' \t\n'
        fi
    
        # Exit if we already have a properly set-up hooks in PROMPT_COMMAND
        # shellcheck disable=SC2016
        local prologue='__bp_precmd_invoke_cmd "$_"'
        local epilogue='__bp_interactive_mode'
        if [[ "$prompt_command" == "$prologue"$'\n'* && "$prompt_command" == *$'\n'"$epilogue" ]]; then
            return 1
        fi
    
        __bp_remove_command_from_prompt_command "$prologue"
        __bp_remove_command_from_prompt_command "$epilogue"
    
        # Install our hooks in PROMPT_COMMAND to allow our trap to know when we've
        # actually entered something.
        # shellcheck disable=SC2128,SC2178 # PROMPT_COMMAND is not an array in bash <= 5.0
        PROMPT_COMMAND=$prologue${PROMPT_COMMAND:+$'\n'$PROMPT_COMMAND}
        if __bp_use_array_prompt_command; then
            PROMPT_COMMAND+=("$epilogue")
        else
            # shellcheck disable=SC2179 # PROMPT_COMMAND is not an array in bash <= 5.0
            PROMPT_COMMAND+=$'\n'$epilogue
        fi
        return 0
    }
    
    # Sets an installation string as part of our PROMPT_COMMAND to install
    # after our session has started. This allows bash-preexec to be included
    # at any point in our bash profile.
    __bp_install_after_session_init() {
        # bash-preexec needs to modify these variables in order to work correctly
        # if it can't, just stop the installation
        __bp_require_not_readonly PROMPT_COMMAND HISTCONTROL HISTTIMEFORMAT || return
        if [[ $__bp_hook_preexec_proc == '__bp_hook_preexec_into_ps0' ]]; then
            __bp_require_not_readonly PS0 || return
        fi
    
        if __bp_use_array_prompt_command; then
            PROMPT_COMMAND+=("${__bp_install_string}")
        else
            local sanitized_prompt_command
            __bp_sanitize_string sanitized_prompt_command "${PROMPT_COMMAND:-}"
            if [[ -n "$sanitized_prompt_command" ]]; then
                # shellcheck disable=SC2178 # PROMPT_COMMAND is not an array in bash <= 5.0
                PROMPT_COMMAND=${sanitized_prompt_command}$'\n'
            fi
            # shellcheck disable=SC2179 # PROMPT_COMMAND is not an array in bash <= 5.0
            PROMPT_COMMAND+=${__bp_install_string}
        fi
    }
    
    # Run our install so long as we're not delaying it.
    if [[ -z "${__bp_delay_install:-}" ]]; then
        __bp_install_after_session_init
    fi
}
export ATUIN_TMUX_POPUP=false
__atuin_bind_ctrl_r=true
__atuin_bind_up_arrow=true
__atuin_initialized=true

if [[ -z "${ATUIN_SESSION:-}" || "${ATUIN_SHLVL:-}" != "$SHLVL" ]]; then
    ATUIN_SESSION=$(atuin uuid)
    export ATUIN_SESSION
    export ATUIN_SHLVL=$SHLVL
fi
ATUIN_STTY=$(stty -g)
ATUIN_HISTORY_ID=""

__atuin_osc133_command_executed() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" && "$ATUIN_HISTORY_ID" != "__bash_preexec_failure__" ]] || return

    printf '\033]133;C\a'
}

__atuin_osc133_command_finished() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" && "$ATUIN_HISTORY_ID" != "__bash_preexec_failure__" ]] || return

    printf '\033]133;D;%s;history_id=%s;session_id=%s\a' "$1" "$ATUIN_HISTORY_ID" "${ATUIN_SESSION:-}"
}

__atuin_osc133_prompt_start=$'\001\033]133;A;cl=line\a\002'
__atuin_osc133_prompt_end=$'\001\033]133;B\a\002'

__atuin_osc133_wrap_prompt() {
    local __atuin_prompt="${PS1-}"
    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_start/}"
    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_end/}"

    if [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]]; then
        PS1="${__atuin_osc133_prompt_start}${__atuin_prompt}${__atuin_osc133_prompt_end}"
    else
        PS1="$__atuin_prompt"
    fi
}

export ATUIN_PREEXEC_BACKEND=$SHLVL:none
__atuin_update_preexec_backend() {
    if [[ ${BLE_ATTACHED-} ]]; then
        ATUIN_PREEXEC_BACKEND=$SHLVL:blesh-${BLE_VERSION-}
    elif [[ ${bash_preexec_imported-} ]]; then
        ATUIN_PREEXEC_BACKEND=$SHLVL:bash-preexec
    elif [[ ${__bp_imported-} ]]; then
        ATUIN_PREEXEC_BACKEND="$SHLVL:bash-preexec (old)"
    else
        ATUIN_PREEXEC_BACKEND=$SHLVL:unknown
    fi
}

__atuin_preexec() {
    # Workaround for old versions of bash-preexec
    if [[ ! ${BLE_ATTACHED-} ]]; then
        # In older versions of bash-preexec, the preexec hook may be called
        # even for the commands run by keybindings.  There is no general and
        # robust way to detect the command for keybindings, but at least we
        # want to exclude Atuin's keybindings.  When the preexec hook is called
        # for a keybinding, the preexec hook for the user command will not
        # fire, so we instead set a fake ATUIN_HISTORY_ID here to notify
        # __atuin_precmd of this failure.
        if [[ $BASH_COMMAND != "$1" ]]; then
            case $BASH_COMMAND in
                '__atuin_history'* | '__atuin_widget_run'* | '__atuin_bash42_dispatch'*)
                    ATUIN_HISTORY_ID=__bash_preexec_failure__
                    return 0 ;;
            esac
        fi
    fi

    # Note: We update ATUIN_PREEXEC_BACKEND on every preexec because blesh's
    # attaching state can dynamically change.
    __atuin_update_preexec_backend

    local id
    id=$(ATUIN_SHELL=bash atuin history start --hook -- "$1" 2>/dev/null)
    export ATUIN_HISTORY_ID=$id
    [[ -n ${__atuin_skip_osc133:-} ]] || __atuin_osc133_command_executed
    __atuin_preexec_time=${EPOCHREALTIME-}
}

__atuin_precmd() {
    local EXIT=$? __atuin_precmd_time=${EPOCHREALTIME-}

    __atuin_osc133_wrap_prompt

    [[ ! $ATUIN_HISTORY_ID ]] && return

    # If the previous preexec hook failed, we manually call __atuin_preexec
    local __atuin_skip_osc133=""
    if [[ $ATUIN_HISTORY_ID == __bash_preexec_failure__ ]]; then
        # This is the command extraction code taken from bash-preexec
        local previous_command
        previous_command=$(
            export LC_ALL=C HISTTIMEFORMAT=''
            builtin history 1 | sed '1 s/^ *[0-9][0-9]*[* ] //'
        )
        __atuin_skip_osc133=1
        __atuin_preexec "$previous_command"
    fi

    local duration=""
    # shellcheck disable=SC2154,SC2309
    if [[ ${BLE_ATTACHED-} && ${_ble_exec_time_ata-} ]]; then
        # With ble.sh, we utilize the shell variable `_ble_exec_time_ata`
        # recorded by ble.sh.  It is more accurate than the measurements by
        # Atuin, which includes the spawn cost of Atuin.  ble.sh uses the
        # special shell variable `EPOCHREALTIME` in bash >= 5.0 with the
        # microsecond resolution, or the builtin `time` in bash < 5.0 with the
        # millisecond resolution.
        duration=${_ble_exec_time_ata}000
    elif ((BASH_VERSINFO[0] >= 5)); then
        # We calculate the high-resolution duration based on EPOCHREALTIME
        # (bash >= 5.0) recorded by precmd/preexec, though it might not be as
        # accurate as `_ble_exec_time_ata` provided by ble.sh because it
        # includes the extra time of the precmd/preexec handling.  Since Bash
        # does not offer floating-point arithmetic, we remove the non-digit
        # characters and perform the integral arithmetic.  The fraction part of
        # EPOCHREALTIME is fixed to have 6 digits in Bash.  We remove all the
        # non-digit characters because the decimal point is not necessarily a
        # period depending on the locale.
        duration=$((${__atuin_precmd_time//[!0-9]} - ${__atuin_preexec_time//[!0-9]}))
        if ((duration >= 0)); then
            duration=${duration}000
        else
            duration="" # clear the result on overflow
        fi
    fi

    [[ -n ${__atuin_skip_osc133:-} ]] || __atuin_osc133_command_finished "$EXIT"
    (atuin history end --hook --exit "$EXIT" ${duration:+"--duration=$duration"} -- "$ATUIN_HISTORY_ID" >/dev/null 2>&1 &)
    export ATUIN_HISTORY_ID=""
}

__atuin_set_ret_value() {
    return ${1:+"$1"}
}

#------------------------------------------------------------------------------
# section: __atuin_accept_line
#
# The function "__atuin_accept_line" is kept for backward compatibility of the
# direct use of __atuin_history in keybindings by users.

# The shell function `__atuin_evaluate_prompt` evaluates prompt sequences in
# $PS1.  We switch the implementation of the shell function
# `__atuin_evaluate_prompt` based on the Bash version because the expansion
# ${PS1@P} is only available in bash >= 4.4.
if ((BASH_VERSINFO[0] >= 5 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4)); then
    __atuin_evaluate_prompt() {
        __atuin_set_ret_value "${__bp_last_ret_value-}" "${__bp_last_argument_prev_command-}"
        __atuin_prompt=${PS1@P}

        # Note: Strip the control characters ^A (\001) and ^B (\002), which
        # Bash internally uses to enclose the escape sequences.  They are
        # produced by '\[' and '\]', respectively, in $PS1 and used to tell
        # Bash that the strings inbetween do not contribute to the prompt
        # width.  After the prompt width calculation, Bash strips those control
        # characters before outputting it to the terminal.  We here strip these
        # characters following Bash's behavior.
        __atuin_prompt=${__atuin_prompt//[$'\001\002']}

        # Count the number of newlines contained in $__atuin_prompt
        __atuin_prompt_offset=${__atuin_prompt//[!$'\n']}
        __atuin_prompt_offset=${#__atuin_prompt_offset}
    }
else
    __atuin_evaluate_prompt() {
        __atuin_prompt='$ '
        __atuin_prompt_offset=0
    }
fi

# The shell function `__atuin_clear_prompt N` outputs terminal control
# sequences to clear the contents of the current and N previous lines.  After
# clearing, the cursor is placed at the beginning of the N-th previous line.
__atuin_clear_prompt_cache=()
__atuin_clear_prompt() {
    local offset=$1
    if [[ ! ${__atuin_clear_prompt_cache[offset]+set} ]]; then
        if [[ ! ${__atuin_clear_prompt_cache[0]+set} ]]; then
            __atuin_clear_prompt_cache[0]=$'\r'$(tput el 2>/dev/null || tput ce 2>/dev/null)
        fi
        if ((offset > 0)); then
            __atuin_clear_prompt_cache[offset]=${__atuin_clear_prompt_cache[0]}$(
                tput cuu "$offset" 2>/dev/null || tput UP "$offset" 2>/dev/null
                tput dl "$offset"  2>/dev/null || tput DL "$offset" 2>/dev/null
                tput il "$offset"  2>/dev/null || tput AL "$offset" 2>/dev/null
            )
        fi
    fi
    printf '%s' "${__atuin_clear_prompt_cache[offset]}"
}

__atuin_accept_line() {
    local __atuin_command=$1

    # Reprint the prompt, accounting for multiple lines
    local __atuin_prompt __atuin_prompt_offset
    __atuin_evaluate_prompt
    __atuin_clear_prompt "$__atuin_prompt_offset"
    printf '%s\n' "$__atuin_prompt$__atuin_command"

    # Add it to the bash history
    history -s "$__atuin_command"

    # Assuming bash-preexec
    # Invoke every function in the preexec array
    local __atuin_preexec_function
    local __atuin_preexec_function_ret_value
    local __atuin_preexec_ret_value=0
    for __atuin_preexec_function in "${preexec_functions[@]:-}"; do
        if type -t "$__atuin_preexec_function" 1>/dev/null; then
            __atuin_set_ret_value "${__bp_last_ret_value:-}"
            "$__atuin_preexec_function" "$__atuin_command"
            __atuin_preexec_function_ret_value=$?
            if [[ $__atuin_preexec_function_ret_value != 0 ]]; then
                __atuin_preexec_ret_value=$__atuin_preexec_function_ret_value
            fi
        fi
    done

    # If extdebug is turned on and any preexec function returns non-zero
    # exit status, we do not run the user command.
    if ! { shopt -q extdebug && ((__atuin_preexec_ret_value)); }; then
        # Note: When a child Bash session is started by enter_accept, if the
        # environment variable READLINE_POINT is present, bash-preexec in the
        # child session does not fire preexec at all because it considers we
        # are inside Atuin's keybinding of the current session.  To avoid
        # propagating the environment variable to the child session, we remove
        # the export attribute of READLINE_LINE and READLINE_POINT.
        export -n READLINE_LINE READLINE_POINT

        # Juggle the terminal settings so that the command can be interacted
        # with
        local __atuin_stty_backup
        __atuin_stty_backup=$(stty -g)
        stty "$ATUIN_STTY"

        # Execute the command.  Note: We need to record $? and $_ after the
        # user command within the same call of "eval" because $_ is otherwise
        # overwritten by the last argument of "eval".
        __atuin_set_ret_value "${__bp_last_ret_value-}" "${__bp_last_argument_prev_command-}"
        eval -- "$__atuin_command"$'\n__bp_last_ret_value=$? __bp_last_argument_prev_command=$_'

        stty "$__atuin_stty_backup"
    fi

    # Execute preprompt commands
    local __atuin_prompt_command
    for __atuin_prompt_command in "${PROMPT_COMMAND[@]}"; do
        __atuin_set_ret_value "${__bp_last_ret_value-}" "${__bp_last_argument_prev_command-}"
        eval -- "$__atuin_prompt_command"
    done
    # Bash will redraw only the line with the prompt after we finish,
    # so to work for a multiline prompt we need to print it ourselves,
    # then go to the beginning of the last line.
    __atuin_evaluate_prompt
    printf '%s' "$__atuin_prompt"
    __atuin_clear_prompt 0
}

#------------------------------------------------------------------------------

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
        escaped_query=$(printf '%s' "$READLINE_LINE" | sed "s/'/'\\\\''/g")
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
            sh -c "PATH='$PATH' ATUIN_SESSION='$ATUIN_SESSION' ATUIN_SHELL=bash ATUIN_QUERY='$escaped_query' atuin search $escaped_args -i 2>'$result_file'"

        if [[ -f "$result_file" ]]; then
            cat "$result_file"
        fi

        __atuin_tmux_popup_cleanup
        trap - EXIT HUP INT TERM
    else
        ATUIN_SHELL=bash ATUIN_QUERY=$READLINE_LINE atuin search "${search_args[@]}" -i 3>&1 1>&2 2>&3 3>&-
    fi
}

__atuin_history() {
    # Default action of the up key: When this function is called with the first
    # argument `--shell-up-key-binding`, we perform Atuin's history search only
    # when the up key is supposed to cause the history movement in the original
    # binding.  We do this only for ble.sh because the up key always invokes
    # the history movement in the plain Bash.
    if [[ ${BLE_ATTACHED-} && ${1-} == --shell-up-key-binding ]]; then
        # When the current cursor position is not in the first line, the up key
        # should move the cursor to the previous line.  While the selection is
        # performed, the up key should not start the history search.
        # shellcheck disable=SC2154 # Note: these variables are set by ble.sh
        if [[ ${_ble_edit_str::_ble_edit_ind} == *$'\n'* || $_ble_edit_mark_active ]]; then
            ble/widget/@nomarked backward-line
            local status=$?
            READLINE_LINE=$_ble_edit_str
            READLINE_POINT=$_ble_edit_ind
            READLINE_MARK=$_ble_edit_mark
            return "$status"
        fi
    fi

    # READLINE_LINE and READLINE_POINT are only supported by bash >= 4.0 or
    # ble.sh.  When it is not supported, we clear them to suppress strange
    # behaviors.
    [[ ${BLE_ATTACHED-} ]] || ((BASH_VERSINFO[0] >= 4)) ||
        READLINE_LINE="" READLINE_POINT=0

    local __atuin_output
    if ! __atuin_output=$(__atuin_search_cmd "$@"); then
        [[ $__atuin_output ]] && printf '%s\n' "$__atuin_output" >&2
        return 1
    fi

    # We do nothing when the search is canceled.
    [[ $__atuin_output ]] || return 0

    if [[ $__atuin_output == __atuin_accept__:* ]]; then
        __atuin_output=${__atuin_output#__atuin_accept__:}

        if [[ ${BLE_ATTACHED-} ]]; then
            ble-edit/content/reset-and-check-dirty "$__atuin_output"
            ble/widget/accept-line
            READLINE_LINE=""
        elif [[ ${__atuin_macro_chain_keymap-} ]]; then
            READLINE_LINE=$__atuin_output
            bind -m "$__atuin_macro_chain_keymap" '"'"$__atuin_macro_chain"'": '"$__atuin_macro_accept_line"
        else
            __atuin_accept_line "$__atuin_output"
            READLINE_LINE=""
        fi

        READLINE_POINT=${#READLINE_LINE}
    else
        READLINE_LINE=$__atuin_output
        READLINE_POINT=${#READLINE_LINE}
        if [[ ! ${BLE_ATTACHED-} ]] && ((BASH_VERSINFO[0] < 4)) && [[ ${__atuin_macro_chain_keymap-} ]]; then
            bind -m "$__atuin_macro_chain_keymap" '"'"$__atuin_macro_chain"'": '"$__atuin_macro_insert_line"
        fi
    fi
}

__atuin_initialize_blesh() {
    # shellcheck disable=SC2154
    [[ ${BLE_VERSION-} ]] && ((_ble_version >= 400)) || return 0

    ble-import contrib/integration/bash-preexec

    # Define and register an autosuggestion source for ble.sh's auto-complete.
    # If you'd like to overwrite this, define the same name of shell function
    # after the $(atuin init bash) line in your .bashrc.  If you do not need
    # the auto-complete source by Atuin, please add the following code to
    # remove the entry after the $(atuin init bash) line in your .bashrc:
    #
    #   ble/util/import/eval-after-load core-complete '
    #     ble/array#remove _ble_complete_auto_source atuin-history'
    #
    function ble/complete/auto-complete/source:atuin-history {
        local suggestion
        suggestion=$(ATUIN_QUERY="$_ble_edit_str" atuin search --cmd-only --limit 1 --search-mode prefix 2>/dev/null)
        [[ $suggestion == "$_ble_edit_str"?* ]] || return 1
        ble/complete/auto-complete/enter h 0 "${suggestion:${#_ble_edit_str}}" '' "$suggestion"
    }
    ble/util/import/eval-after-load core-complete '
        ble/array#unshift _ble_complete_auto_source atuin-history'

    # @env BLE_SESSION_ID: `atuin doctor` references the environment variable
    # BLE_SESSION_ID.  We explicitly export the variable because it was not
    # exported in older versions of ble.sh.
    [[ ${BLE_SESSION_ID-} ]] && export BLE_SESSION_ID
}
__atuin_initialize_blesh
BLE_ONLOAD+=(__atuin_initialize_blesh)
precmd_functions+=(__atuin_precmd)
preexec_functions+=(__atuin_preexec)

#------------------------------------------------------------------------------
# section: atuin-bind

__atuin_widget=()

__atuin_widget_save() {
    local data=$1
    for REPLY in "${!__atuin_widget[@]}"; do
        if [[ ${__atuin_widget[REPLY]} == "$data" ]]; then
            return 0
        fi
    done
    # shellcheck disable=SC2154
    REPLY=${#__atuin_widget[*]}
    __atuin_widget[REPLY]=$data
}

__atuin_widget_run() {
    local data=${__atuin_widget[$1]}
    local keymap=${data%%:*} widget=${data#*:}
    local __atuin_macro_chain_keymap=$keymap
    bind -m "$keymap" '"'"$__atuin_macro_chain"'": ""'
    builtin eval -- "$widget"
}

# To realize the enter_accept feature in a robust way, we need to call the
# readline bindable function `accept-line'.  However, there is no way to call
# `accept-line' from the shell script.  To call the bindable function
# `accept-line', we may utilize string macros of readline.  When we bind KEYSEQ
# to a WIDGET that wants to conditionally call `accept-line' at the end, we
# perform two-step dispatching:
#
# 1. [KEYSEQ -> IKEYSEQ1 IKEYSEQ2]---We first translate KEYSEQ to two
#   intermediate key sequences IKEYSEQ1 and IKEYSEQ2 using string macros.  For
#   example, when we bind `__atuin_history` to \C-r, this step can be set up by
#   `bind '"\C-r": "IKEYSEQ1IKEYSEQ2"'`.
#
# 2. [IKEYSEQ1 -> WIDGET]---Then, IKEYSEQ1 is bound to the WIDGET, and the
#   binding of IKEYSEQ2 is dynamically determined by WIDGET.  For example, when
#   we bind `__atuin_history` to \C-r, this step can be set up by `bind -x
#   '"IKEYSEQ1": WIDGET'`.
#
# 3. [IKEYSEQ2 -> accept-line] or [IKEYSEQ2 -> ""]---To request the execution
#   of `accept-line', WIDGET can change the binding of IKEYSEQ2 by running
#   `bind '"IKEYSEQ2": accept-line''.  Otherwise, WIDGET can change the binding
#   of IKEYSEQ2 to no-op by running `bind '"IKEYSEQ2": ""'`.
#
# For the choice of the intermediate key sequences, we want to choose key
# sequences that are unlikely to conflict with others.  In addition, we want to
# avoid a key sequence containing \e because keymap "vi-insert" stops
# processing key sequences containing \e in older versions of Bash.  We have
# used \e[0;<m>A (a variant of the [up] key with modifier <m>) in Atuin 3.10.0
# for intermediate key sequences, but this contains \e and caused a problem.
# Instead, we use \C-x\C-_A<n>\a, which starts with \C-x\C-_ (an unlikely
# two-byte combination) and A (represents the initial letter of Atuin),
# followed by the payload <n> and the terminator \a (BEL, \C-g).

__atuin_macro_chain='\C-x\C-_A0\a'
for __atuin_keymap in emacs vi-insert vi-command; do
    bind -m "$__atuin_keymap" "\"$__atuin_macro_chain\": \"\""
done
unset -v __atuin_keymap

if ((BASH_VERSINFO[0] >= 5 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3)); then
    # In Bash >= 4.3

    __atuin_macro_accept_line=accept-line

    __atuin_bind_impl() {
        local keymap=$1 keyseq=$2 command=$3

        # Note: In Bash <= 5.0, the table for `bind -x` from the keyseq to the
        # command is shared by all the keymaps (emacs, vi-insert, and
        # vi-command), so one cannot safely bind different command strings to
        # the same keyseq in different keymaps.  Therefore, the command string
        # and the keyseq need to be globally in one-to-one correspondence in
        # all the keymaps.
        local REPLY
        __atuin_widget_save "$keymap:$command"
        local widget=$REPLY
        local ikeyseq1='\C-x\C-_A'$((1 + widget))'\a'
        local ikeyseq2=$__atuin_macro_chain

        if ((BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] == 1)); then
            # Workaround for Bash 5.1: Bash 5.1 has a bug that overwriting an
            # existing "bind -x" keybinding breaks other existing "bind -x"
            # keybindings [1,2].  To work around the problem, we explicitly
            # unbind an existing keybinding before overwriting it.
            #
            # [1] https://lists.gnu.org/archive/html/bug-bash/2021-04/msg00135.html
            # [2] https://github.com/atuinsh/atuin/issues/962#issuecomment-3451132291
            bind -m "$keymap" -r "$keyseq"
        fi

        bind -m "$keymap" "\"$keyseq\": \"$ikeyseq1$ikeyseq2\""
        bind -m "$keymap" -x "\"$ikeyseq1\": __atuin_widget_run $widget"
    }

    __atuin_bind_blesh_onload() {
        # In ble.sh, we need to enable unrecognized CSI sequences like \e[0;0A,
        # which are discarded by ble.sh by default.  Note: In Bash <= 4.2, we
        # do not need to unset "decode_error_cseq_discard" because \e[0;<m>A is
        # used only for the macro chaining (which is unused by ble.sh) in Bash
        # <= 4.2.
        bleopt decode_error_cseq_discard=
    }
    if [[ ${BLE_VERSION-} ]]; then
        __atuin_bind_blesh_onload
    fi
    BLE_ONLOAD+=(__atuin_bind_blesh_onload)
else
    # In Bash <= 4.2, "bind -x" cannot bind a shell command to a keyseq having
    # more than two bytes, so we need to work with only two-byte sequences.
    #
    # However, the number of available combinations of two-byte sequences is
    # limited.  To minimize the number of key sequences used by Atuin, instead
    # of specifying a widget by its own intermediate sequence, we specify a
    # widget by a fixed-length sequence of multiple two-byte sequences.  More
    # specifically, instead of IKEYSEQ1, we use IKS1 IKS2 IKS3 [IKS4 IKS5]
    # IKSX, where IKS1..IKS5 just stores its information to a global variable,
    # and IKSX collects all the information and determine and call the actual
    # widget based on the stored information. Each of IKn (n=1..5) is one of
    # the two reserved sequences, $__atuin_bash42_code0 and
    # $__atuin_bash42_code1.  IKSX is fixed to be $__atuin_bash42_code2.
    #
    # For the choices of the special key sequences, we consider \C-xQ, \C-xR,
    # and \C-xS.  In the emacs editing mode of Bash, \C-x is used as a prefix
    # key, i.e., it is used for the beginning key of the keybindings with
    # multiple keys, so \C-x is unlikely to be used for a single-key binding by
    # the user.  Also, \C-x is not used in the vi editing mode by default.  The
    # combinations \C-xQ..\C-xS are also unlikely be used because we need to
    # switch the modifier keys from Control to Shift to input these sequences,
    # and these are not easy to input.
    __atuin_bash42_code0='\C-xQ'
    __atuin_bash42_code1='\C-xR'
    __atuin_bash42_code2='\C-xS'

    __atuin_bash42_encode() {
        REPLY=
        local n=$1 min_width=${2-}
        while
            if ((n % 2 == 0)); then
                REPLY=$__atuin_bash42_code0$REPLY
            else
                REPLY=$__atuin_bash42_code1$REPLY
            fi
            (((n /= 2) || ${#REPLY} / ${#__atuin_bash42_code0} < min_width))
        do :; done
    }

    __atuin_bash42_bind() {
        local __atuin_keymap
        for __atuin_keymap in emacs vi-insert vi-command; do
            bind -m "$__atuin_keymap" -x '"'"$__atuin_bash42_code0"'": __atuin_bash42_dispatch_selector+=0'
            bind -m "$__atuin_keymap" -x '"'"$__atuin_bash42_code1"'": __atuin_bash42_dispatch_selector+=1'
            bind -m "$__atuin_keymap" -x '"'"$__atuin_bash42_code2"'": __atuin_bash42_dispatch'
        done
    }
    __atuin_bash42_bind
    # In Bash <= 4.2, there is no way to read users' "bind -x" settings, so we
    # need to explicitly perform "bind -x" when ble.sh is loaded.
    BLE_ONLOAD+=(__atuin_bash42_bind)

    if ((BASH_VERSINFO[0] >= 4)); then
        __atuin_macro_accept_line=accept-line
    else
        # Note: We rewrite the command line and invoke `accept-line'.  In
        # bash <= 3.2, there is no way to rewrite the command line from the
        # shell script, so we rewrite it using a macro and
        # `shell-expand-line'.
        #
        # Note: Concerning the key sequences to invoke bindable functions
        # such as "\C-x\C-_A1\a", another option is to use
        # "\exbegginning-of-line\r", etc. to make it consistent with bash
        # >= 5.3.  However, an older Bash configuration can still conflict
        # on [M-x].  The conflict is more likely than \C-x\C-_A1\a.
        for __atuin_keymap in emacs vi-insert vi-command; do
            bind -m "$__atuin_keymap" '"\C-x\C-_A1\a": beginning-of-line'
            bind -m "$__atuin_keymap" '"\C-x\C-_A2\a": kill-line'
            # shellcheck disable=SC2016
            bind -m "$__atuin_keymap" '"\C-x\C-_A3\a": "$READLINE_LINE"'
            bind -m "$__atuin_keymap" '"\C-x\C-_A4\a": shell-expand-line'
            bind -m "$__atuin_keymap" '"\C-x\C-_A5\a": accept-line'
            bind -m "$__atuin_keymap" '"\C-x\C-_A6\a": end-of-line'
        done
        unset -v __atuin_keymap

        bind -m vi-command '"\C-x\C-_A7\a": vi-insertion-mode'
        bind -m vi-insert  '"\C-x\C-_A7\a": vi-movement-mode'

        # "\C-x\C-_A10\a": Replace the command line with READLINE_LINE.  When we are
        #   in the vi-command keymap, we go to vi-insert, input
        #   "$READLINE_LINE", and come back to vi-command.
        bind -m emacs      '"\C-x\C-_A10\a": "\C-x\C-_A1\a\C-x\C-_A2\a\C-x\C-_A3\a\C-x\C-_A4\a"'
        bind -m vi-insert  '"\C-x\C-_A10\a": "\C-x\C-_A1\a\C-x\C-_A2\a\C-x\C-_A3\a\C-x\C-_A4\a"'
        bind -m vi-command '"\C-x\C-_A10\a": "\C-x\C-_A1\a\C-x\C-_A2\a\C-x\C-_A7\a\C-x\C-_A3\a\C-x\C-_A7\a\C-x\C-_A4\a"'

        __atuin_macro_accept_line='"\C-x\C-_A10\a\C-x\C-_A5\a"'
        __atuin_macro_insert_line='"\C-x\C-_A10\a\C-x\C-_A6\a"'
    fi

    __atuin_bash42_dispatch_selector=

    __atuin_bash42_dispatch() {
        local s=$__atuin_bash42_dispatch_selector
        __atuin_bash42_dispatch_selector=
        __atuin_widget_run "$((2#0$s))"
    }

    __atuin_bind_impl() {
        local keymap=$1 keyseq=$2 command=$3

        __atuin_widget_save "$keymap:$command"
        __atuin_bash42_encode "$REPLY"
        local macro=$REPLY$__atuin_bash42_code2$__atuin_macro_chain

        bind -m "$keymap" "\"$keyseq\": \"$macro\""
    }
fi

atuin-bind() {
    local keymap=
    local OPTIND=1 OPTARG="" OPTERR=0 flag
    while getopts ':m:' flag "$@"; do
        case $flag in
            m) keymap=$OPTARG ;;
            *)
                printf '%s\n' "atuin-bind: unrecognized option '-$flag'" >&2
                return 2
                ;;
        esac
    done
    shift "$((OPTIND - 1))"

    if (($# != 2)); then
        printf '%s\n' 'usage: atuin-bind [-m keymap] keyseq widget' >&2
        return 2
    fi

    local keyseq=$1
    [[ $keymap ]] || keymap=$(bind -v | awk '$2 == "keymap" { print $3 }')
    case $keymap in
        emacs-meta) keymap=emacs keyseq='\e'$keyseq ;;
        emacs-ctlx) keymap=emacs keyseq='\C-x'$keyseq ;;
        emacs*)     keymap=emacs ;;
        vi-insert)  ;;
        vi*)        keymap=vi-command ;;
        *)
            printf '%s\n' "atuin-bind: unknown keymap '$keymap'" >&2
            return 2 ;;
    esac

    local command=$2 widget=${2%%[[:blank:]]*}
    case $widget in
        atuin-search)          command=${2/#"$widget"/__atuin_history} ;;
        atuin-search-emacs)    command=${2/#"$widget"/__atuin_history --keymap-mode=emacs} ;;
        atuin-search-viins)    command=${2/#"$widget"/__atuin_history --keymap-mode=vim-insert} ;;
        atuin-search-vicmd)    command=${2/#"$widget"/__atuin_history --keymap-mode=vim-normal} ;;
        atuin-up-search)       command=${2/#"$widget"/__atuin_history --shell-up-key-binding} ;;
        atuin-up-search-emacs) command=${2/#"$widget"/__atuin_history --shell-up-key-binding --keymap-mode=emacs} ;;
        atuin-up-search-viins) command=${2/#"$widget"/__atuin_history --shell-up-key-binding --keymap-mode=vim-insert} ;;
        atuin-up-search-vicmd) command=${2/#"$widget"/__atuin_history --shell-up-key-binding --keymap-mode=vim-normal} ;;
    esac

    __atuin_bind_impl "$keymap" "$keyseq" "$command"
}

#------------------------------------------------------------------------------

# shellcheck disable=SC2154
if [[ $__atuin_bind_ctrl_r == true ]]; then
    # Note: We do not overwrite [C-r] in the vi-command keymap because we do
    # not want to overwrite "redo", which is already bound to [C-r] in the
    # vi_nmap keymap in ble.sh.
    atuin-bind -m emacs      '\C-r' atuin-search-emacs
    atuin-bind -m vi-insert  '\C-r' atuin-search-viins
    atuin-bind -m vi-command '/'    atuin-search-emacs
fi

# shellcheck disable=SC2154
if [[ $__atuin_bind_up_arrow == true ]]; then
    atuin-bind -m emacs      '\e[A' atuin-up-search-emacs
    atuin-bind -m emacs      '\eOA' atuin-up-search-emacs
    atuin-bind -m vi-insert  '\e[A' atuin-up-search-viins
    atuin-bind -m vi-insert  '\eOA' atuin-up-search-viins
    atuin-bind -m vi-command '\e[A' atuin-up-search-vicmd
    atuin-bind -m vi-command '\eOA' atuin-up-search-vicmd
    atuin-bind -m vi-command 'k'    atuin-up-search-vicmd
fi

if command -v __atuin_load_builtin_preexec > /dev/null; then
    if [[ -z ${ATUIN_NO_BUILTIN_PREEXEC-} ]]; then
        __atuin_update_preexec_backend
        if [[ $ATUIN_PREEXEC_BACKEND == *:unknown ]]; then
            __atuin_load_builtin_preexec
        fi
    fi
    # Free the function from memory
    unset -f __atuin_load_builtin_preexec
fi
# Question mark at start of line - natural language mode
_atuin_ai_question_mark() {
    # If buffer is empty or just contains '?', trigger natural language mode
    if [[ -z "$READLINE_LINE" || "$READLINE_LINE" == "?" ]]; then
        READLINE_LINE=""
        READLINE_POINT=0

        # Close the semantic prompt zone (OSC 133 C) so terminals with
        # shell integration don't erase the TUI's output during their
        # resize-time prompt reflow.
        printf '\033]133;C\007' > /dev/tty
        local output
        output=$(atuin ai inline --hook 3>&1 1>&2 2>&3)

        if [[ $output == __atuin_ai_print__:* ]]; then
            echo "${output#__atuin_ai_print__:}"
            READLINE_LINE=""
            READLINE_POINT=0
        elif [[ $output == __atuin_ai_cancel__ ]]; then
            READLINE_LINE=""
            READLINE_POINT=0
        elif [[ $output == __atuin_ai_execute__:* ]]; then
            # Execute the command immediately
            READLINE_LINE=${output#__atuin_ai_execute__:}
            READLINE_POINT=${#READLINE_LINE}
            # Note: We can't directly execute in bash bind -x, but we can
            # use a workaround by binding to a macro that accepts the line
            bind '"\C-x\C-a": accept-line'
            bind -x '"\C-x\C-e": _atuin_ai_question_mark'
        elif [[ $output == __atuin_ai_insert__:* ]]; then
            # Insert the command for editing
            READLINE_LINE=${output#__atuin_ai_insert__:}
            READLINE_POINT=${#READLINE_LINE}
        elif [[ -n $output ]]; then
            # Default: insert for editing
            READLINE_LINE=$output
            READLINE_POINT=${#READLINE_LINE}
        fi
    else
        # Not at empty prompt, just insert the question mark
        READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}?${READLINE_LINE:READLINE_POINT}"
        ((READLINE_POINT++))
    fi
}

# Set up keybindings
# Bash requires special handling: we use bind -x for the function,
# but need a two-step approach for execute mode
__atuin_ai_accept_line=""

_atuin_ai_question_mark_wrapper() {
    _atuin_ai_question_mark
    if [[ -n "$__atuin_ai_accept_line" ]]; then
        __atuin_ai_accept_line=""
    fi
}

bind -x '"?": _atuin_ai_question_mark'
}

# --- fnm init ---
export PATH="/run/user/1000/fnm_multishells/12489_1787724455263/bin":"$PATH"
export FNM_MULTISHELL_PATH="/run/user/1000/fnm_multishells/12489_1787724455263"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_DIR="/home/john/.local/share/fnm"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="true"
export FNM_ARCH="x64"
__fnm_use_if_file_found() {
    if [[ -f .node-version || -f .nvmrc || -f package.json ]]; then
    fnm use --silent-if-unchanged
fi

}

__fnmcd() {
    \cd "$@" || return $?
    __fnm_use_if_file_found
}

alias cd=__fnmcd
__fnm_use_if_file_found


# --- fzf init ---
### key-bindings.bash ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_COMMAND
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

if [[ $- =~ i ]]; then


# Key bindings
# ------------

#----BEGIN shfmt
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

__fzf_select__() {
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" |
    while read -r item; do
      printf '%q ' "$item" # escape special chars
    done
}

__fzfcmd() {
  [[ -n ${TMUX_PANE-} ]] && { [[ ${FZF_TMUX:-0} != 0 ]] || [[ -n ${FZF_TMUX_OPTS-} ]]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  local selected="$(__fzf_select__ "$@")"
  READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}$selected${READLINE_LINE:READLINE_POINT}"
  READLINE_POINT=$((READLINE_POINT + ${#selected}))
}

__fzf_cd__() {
  local dir
  dir=$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
      FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
  ) && printf 'builtin cd -- %q' "$(builtin unset CDPATH && builtin cd -- "$dir" && builtin pwd)"
}

if command -v perl > /dev/null; then
  __fzf_history__() {
    local output script
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; s/\n/\n\t/gm; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) command perl -n -l0 -e "$script" |
        FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '"$'\t'"↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} +m --read0") \
        FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=$(command perl -pe 's/^\d*\t//' <<< "$output")
    if [[ -z $READLINE_POINT ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
else # awk - fallback for POSIX systems
  __fzf_history__() {
    local output script
    [[ $(HISTTIMEFORMAT='' builtin history 1) =~ [[:digit:]]+ ]] # how many history entries
    script='function P(b) { ++n; sub(/^[ *]/, "", b); if (!seen[b]++) { printf "%d\t%s%c", '$((BASH_REMATCH + 1))' - n, b, 0 } }
    NR==1 { b = substr($0, 2); next }
    /^\t/ { P(b); b = substr($0, 2); next }
    { b = b RS $0 }
    END { if (NR) P(b) }'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 2> /dev/null | # ( $'\t '<lines>$'\n' )* ; <lines> ::= [^\n]* ( $'\n'<lines> )*
        __fzf_exec_awk "$script" |               # ( <counter>$'\t'<lines>$'\000' )*
        FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '"$'\t'"↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} +m --read0") \
        FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z $READLINE_POINT ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
fi

# Required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

if ((BASH_VERSINFO[0] < 4)); then
  # CTRL-T - Paste the selected file path into the command line
  if [[ ${FZF_CTRL_T_COMMAND-x} != "" ]]; then
    bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f\C-y\ey\C-_"'
    bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
    bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
    if [[ -n ${FZF_CTRL_R_COMMAND-} ]]; then
      echo "warning: FZF_CTRL_R_COMMAND is set to a custom command, but custom commands are not yet supported for CTRL-R" >&2
    fi
    bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u`__fzf_history__`\e\C-e\er"'
    bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
    bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
  fi
else
  # CTRL-T - Paste the selected file path into the command line
  if [[ ${FZF_CTRL_T_COMMAND-x} != "" ]]; then
    bind -m emacs-standard -x '"\C-t": fzf-file-widget'
    bind -m vi-command -x '"\C-t": fzf-file-widget'
    bind -m vi-insert -x '"\C-t": fzf-file-widget'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
    if [[ -n ${FZF_CTRL_R_COMMAND-} ]]; then
      echo "warning: FZF_CTRL_R_COMMAND is set to a custom command, but custom commands are not yet supported for CTRL-R" >&2
    fi
    bind -m emacs-standard -x '"\C-r": __fzf_history__'
    bind -m vi-command -x '"\C-r": __fzf_history__'
    bind -m vi-insert -x '"\C-r": __fzf_history__'
  fi
fi

# ALT-C - cd into the selected directory
if [[ ${FZF_ALT_C_COMMAND-x} != "" ]]; then
  bind -m emacs-standard '"\ec": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d\C-y\ey\C-_"'
  bind -m vi-command '"\ec": "\C-z\ec\C-z"'
  bind -m vi-insert '"\ec": "\C-z\ec\C-z"'
fi
#----END shfmt

fi
### end: key-bindings.bash ###
### completion.bash ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ completion.bash
#
# - $FZF_TMUX                 (default: 0)
# - $FZF_TMUX_OPTS            (default: empty)
# - $FZF_COMPLETION_TRIGGER   (default: '**')
# - $FZF_COMPLETION_OPTS      (default: empty)
# - $FZF_COMPLETION_PATH_OPTS (default: empty)
# - $FZF_COMPLETION_DIR_OPTS  (default: empty)

if [[ $- =~ i ]]; then


# To use custom commands instead of find, override _fzf_compgen_{path,dir}
#
#   _fzf_compgen_path() {
#     echo "$1"
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
#       -a -not -path "$1" -print 2> /dev/null | command sed 's@^\./@@'
#   }
#
#   _fzf_compgen_dir() {
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
#       -a -not -path "$1" -print 2> /dev/null | command sed 's@^\./@@'
#   }

###########################################################

#----BEGIN shfmt
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
  if [[ "$(type -t _fzf_comprun 2>&1)" == function ]]; then
    _fzf_comprun "$@"
  elif [[ -n ${TMUX_PANE-} ]] && { [[ ${FZF_TMUX:-0} != 0 ]] || [[ -n ${FZF_TMUX_OPTS-} ]]; }; then
    shift
    fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- "$@"
  else
    shift
    fzf "$@"
  fi
}

__fzf_orig_completion() {
  local l comp f cmd
  while read -r l; do
    if [[ $l =~ ^(.*\ -F)\ *([^ ]*).*\ ([^ ]*)$ ]]; then
      comp="${BASH_REMATCH[1]}"
      f="${BASH_REMATCH[2]}"
      cmd="${BASH_REMATCH[3]}"
      [[ $f == _fzf_* ]] && continue
      printf -v "_fzf_orig_completion_${cmd//[^A-Za-z0-9_]/_}" "%s" "${comp} %s ${cmd} #${f}"
      if [[ $l == *" -o nospace "* ]] && [[ ${__fzf_nospace_commands-} != *" $cmd "* ]]; then
        __fzf_nospace_commands="${__fzf_nospace_commands-} $cmd "
      fi
    fi
  done
}

# @param $1 cmd - Command name for which the original completion is searched
# @var[out] REPLY - Original function name is returned
__fzf_orig_completion_get_orig_func() {
  local cmd orig_var orig
  cmd=$1
  orig_var="_fzf_orig_completion_${cmd//[^A-Za-z0-9_]/_}"
  orig="${!orig_var-}"
  REPLY="${orig##*#}"
  [[ $REPLY ]] && type "$REPLY" &> /dev/null
}

# @param $1 cmd - Command name for which the original completion is searched
# @param $2 func - Fzf's completion function to replace the original function
# @var[out] REPLY - Completion setting is returned as a string to "eval"
__fzf_orig_completion_instantiate() {
  local cmd func orig_var orig
  cmd=$1
  func=$2
  orig_var="_fzf_orig_completion_${cmd//[^A-Za-z0-9_]/_}"
  orig="${!orig_var-}"
  orig="${orig%#*}"
  [[ $orig == *' %s '* ]] || return 1
  printf -v REPLY "$orig" "$func"
}

_fzf_opts_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts="
    +c --no-color
    +i --no-ignore-case
    +s --no-sort
    +x --no-extended
    --ansi
    --bash
    --bind
    --border
    --border-label
    --border-label-pos
    --color
    --cycle
    --disabled
    --ellipsis
    --expect
    --filepath-word
    --fish
    --header
    --header-first
    --header-lines
    --height
    --highlight-line
    --history
    --history-size
    --hscroll-off
    --info
    --jump-labels
    --keep-right
    --layout
    --listen
    --listen-unsafe
    --literal
    --man
    --margin
    --marker
    --min-height
    --no-bold
    --no-clear
    --no-hscroll
    --no-mouse
    --no-scrollbar
    --no-separator
    --no-unicode
    --padding
    --pointer
    --preview
    --preview-label
    --preview-label-pos
    --preview-window
    --print-query
    --print0
    --prompt
    --read0
    --reverse
    --scheme
    --scroll-off
    --separator
    --sync
    --tabstop
    --tac
    --tiebreak
    --tmux
    --track
    --version
    --with-nth
    --with-shell
    --wrap
    --zsh
    -0 --exit-0
    -1 --select-1
    -d --delimiter
    -e --exact
    -f --filter
    -h --help
    -i --ignore-case
    -m --multi
    -n --nth
    -q --query
    --"

  case "${prev}" in
    --scheme)
      COMPREPLY=($(compgen -W "default path history" -- "$cur"))
      return 0
      ;;
    --tiebreak)
      COMPREPLY=($(compgen -W "length chunk begin end index" -- "$cur"))
      return 0
      ;;
    --color)
      COMPREPLY=($(compgen -W "dark light 16 bw no" -- "$cur"))
      return 0
      ;;
    --layout)
      COMPREPLY=($(compgen -W "default reverse reverse-list" -- "$cur"))
      return 0
      ;;
    --info)
      COMPREPLY=($(compgen -W "default right hidden inline inline-right" -- "$cur"))
      return 0
      ;;
    --preview-window)
      COMPREPLY=($(compgen -W "
      default
      hidden
      nohidden
      wrap
      nowrap
      cycle
      nocycle
      up top
      down bottom
      left
      right
      rounded border border-rounded
      sharp border-sharp
      border-bold
      border-block
      border-thinblock
      border-double
      noborder border-none
      border-horizontal
      border-vertical
      border-up border-top
      border-down border-bottom
      border-left
      border-right
      follow
      nofollow" -- "$cur"))
      return 0
      ;;
    --border)
      COMPREPLY=($(compgen -W "rounded sharp bold block thinblock double horizontal vertical top bottom left right none" -- "$cur"))
      return 0
      ;;
    --border-label-pos | --preview-label-pos)
      COMPREPLY=($(compgen -W "center bottom top" -- "$cur"))
      return 0
      ;;
  esac

  if [[ $cur =~ ^-|\+ ]]; then
    COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
    return 0
  fi

  return 0
}

_fzf_handle_dynamic_completion() {
  local cmd ret REPLY orig_cmd orig_complete
  cmd="$1"
  shift
  orig_cmd="$1"
  if __fzf_orig_completion_get_orig_func "$cmd"; then
    "$REPLY" "$@"
  elif [[ -n ${_fzf_completion_loader-} ]]; then
    orig_complete=$(complete -p "$orig_cmd" 2> /dev/null)
    $_fzf_completion_loader "$@"
    ret=$?
    # _completion_loader may not have updated completion for the command
    if [[ "$(complete -p "$orig_cmd" 2> /dev/null)" != "$orig_complete" ]]; then
      __fzf_orig_completion < <(complete -p "$orig_cmd" 2> /dev/null)
      __fzf_orig_completion_get_orig_func "$cmd" || ret=1

      # Update orig_complete by _fzf_orig_completion entry
      [[ $orig_complete =~ ' -F '(_fzf_[^ ]+)' ' ]] &&
        __fzf_orig_completion_instantiate "$cmd" "${BASH_REMATCH[1]}" &&
        orig_complete=$REPLY

      if [[ ${__fzf_nospace_commands-} == *" $orig_cmd "* ]]; then
        eval "${orig_complete/ -F / -o nospace -F }"
      else
        eval "$orig_complete"
      fi
    fi
    [[ $ret -eq 0 ]] && return 124
    return $ret
  fi
}

__fzf_generic_path_completion() {
  local cur base dir leftover matches trigger cmd
  cmd="${COMP_WORDS[0]}"
  if [[ $cmd == \\* ]]; then
    cmd="${cmd:1}"
  fi
  COMPREPLY=()
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [[ $COMP_CWORD -ge 0 ]] && cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ $cur == *"$trigger" ]] && [[ $cur != *'$('* ]] && [[ $cur != *':='* ]] && [[ $cur != *'`'* ]]; then
    base=${cur:0:${#cur}-${#trigger}}
    eval "base=$base" 2> /dev/null || return

    dir=
    [[ $base == *"/"* ]] && dir="$base"
    while true; do
      if [[ -z $dir ]] || [[ -d $dir ]]; then
        leftover=${base/#"$dir"/}
        leftover=${leftover/#\//}
        [[ -z $dir ]] && dir='.'
        [[ $dir != "/" ]] && dir="${dir/%\//}"
        matches=$(
          export FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --scheme=path" "${FZF_COMPLETION_OPTS-} $2")
          unset FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS_FILE
          if declare -F "$1" > /dev/null; then
            eval "$1 $(printf %q "$dir")" | __fzf_comprun "$4" -q "$leftover"
          else
            if [[ $1 =~ dir ]]; then
              walker=dir,follow
              eval "rest=(${FZF_COMPLETION_DIR_OPTS-})"
            else
              walker=file,dir,follow,hidden
              eval "rest=(${FZF_COMPLETION_PATH_OPTS-})"
            fi
            __fzf_comprun "$4" -q "$leftover" --walker "$walker" --walker-root="$dir" "${rest[@]}"
          fi | while read -r item; do
            printf "%q " "${item%$3}$3"
          done
        )
        matches=${matches% }
        [[ -z $3 ]] && [[ ${__fzf_nospace_commands-} == *" ${COMP_WORDS[0]} "* ]] && matches="$matches "
        if [[ -n $matches ]]; then
          COMPREPLY=("$matches")
        else
          COMPREPLY=("$cur")
        fi
        # To redraw line after fzf closes (printf '\e[5n')
        bind '"\e[0n": redraw-current-line' 2> /dev/null
        printf '\e[5n'
        return 0
      fi
      dir=$(command dirname "$dir")
      [[ $dir =~ /$ ]] || dir="$dir"/
    done
  else
    shift
    shift
    shift
    _fzf_handle_dynamic_completion "$cmd" "$@"
  fi
}

_fzf_complete() {
  # Split arguments around --
  local args rest str_arg i sep
  args=("$@")
  sep=
  for i in "${!args[@]}"; do
    if [[ ${args[$i]} == -- ]]; then
      sep=$i
      break
    fi
  done
  if [[ -n $sep ]]; then
    str_arg=
    rest=("${args[@]:$((sep + 1)):${#args[@]}}")
    args=("${args[@]:0:sep}")
  else
    str_arg=$1
    args=()
    shift
    rest=("$@")
  fi

  local cur selected trigger cmd post
  post="$(caller 0 | __fzf_exec_awk '{print $2}')_post"
  type -t "$post" > /dev/null 2>&1 || post='command cat'

  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  cmd="${COMP_WORDS[0]}"
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ $cur == *"$trigger" ]] && [[ $cur != *'$('* ]] && [[ $cur != *':='* ]] && [[ $cur != *'`'* ]]; then
    cur=${cur:0:${#cur}-${#trigger}}

    selected=$(
      FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse" "${FZF_COMPLETION_OPTS-} $str_arg") \
      FZF_DEFAULT_OPTS_FILE='' \
        __fzf_comprun "${rest[0]}" "${args[@]}" -q "$cur" | eval "$post" | command tr '\n' ' '
    )
    selected=${selected% } # Strip trailing space not to repeat "-o nospace"
    if [[ -n $selected ]]; then
      COMPREPLY=("$selected")
    else
      COMPREPLY=("$cur")
    fi
    bind '"\e[0n": redraw-current-line' 2> /dev/null
    printf '\e[5n'
    return 0
  else
    _fzf_handle_dynamic_completion "$cmd" "${rest[@]}"
  fi
}

_fzf_path_completion() {
  __fzf_generic_path_completion _fzf_compgen_path "-m" "" "$@"
}

# Deprecated. No file only completion.
_fzf_file_completion() {
  _fzf_path_completion "$@"
}

_fzf_dir_completion() {
  __fzf_generic_path_completion _fzf_compgen_dir "" "/" "$@"
}

_fzf_complete_kill() {
  _fzf_proc_completion "$@"
}

_fzf_proc_completion() {
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
        command ps --everyone --full --windows                 # For cygwin
    )
}

_fzf_proc_completion_post() {
  __fzf_exec_awk '{print $2}'
}

# To use custom hostname lists, override __fzf_list_hosts.
# The function is expected to print hostnames, one per line as well as in the
# desired sorting and with any duplicates removed, to standard output.
#
# e.g.
#   # Use bash-completions’s _known_hosts_real() for getting the list of hosts
#   __fzf_list_hosts() {
#     # Set the local attribute for any non-local variable that is set by _known_hosts_real()
#     local COMPREPLY=()
#     _known_hosts_real ''
#     printf '%s\n' "${COMPREPLY[@]}" | command sort -u --version-sort
#   }
if ! declare -F __fzf_list_hosts > /dev/null; then
  __fzf_list_hosts() {
    command sort -u \
      <(
        # Note: To make the pathname expansion of "~/.ssh/config.d/*" work
        # properly, we need to adjust the related shell options.  We need to
        # unset "set -f" and "GLOBIGNORE", which disable the pathname expansion
        # totally or partially.  We need to unset "dotglob" and "nocaseglob" to
        # avoid matching unwanted files.  We need to unset "failglob" to avoid
        # outputting the error messages to the terminal when no matching is
        # found.  We need to set "nullglob" to avoid attempting to read the
        # literal filename '~/.ssh/config.d/*' when no matching is found.
        set +f
        GLOBIGNORE=
        shopt -u dotglob nocaseglob failglob
        shopt -s nullglob

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

_fzf_host_completion() {
  _fzf_complete +m -- "$@" < <(__fzf_list_hosts)
}

# Values for $1 $2 $3 are described here
# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
# > the first argument ($1) is the name of the command whose arguments are being completed,
# > the second argument ($2) is the word being completed,
# > and the third argument ($3) is the word preceding the word being completed on the current command line.
_fzf_complete_ssh() {
  case $3 in
    -i | -F | -E)
      _fzf_path_completion "$@"
      ;;
    *)
      local user=
      [[ $2 =~ '@' ]] && user="${2%%@*}@"
      _fzf_complete +m -- "$@" < <(__fzf_list_hosts | __fzf_exec_awk -v user="$user" '{print user $0}')
      ;;
  esac
}

_fzf_var_completion() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | command sed -En 's|^declare [^ ]+ ([^=]+).*|\1|p'
  )
}

_fzf_alias_completion() {
  _fzf_complete -m -- "$@" < <(
    alias | command sed -En 's|^alias ([^=]+).*|\1|p'
  )
}

# fzf options
complete -o default -F _fzf_opts_completion fzf
# fzf-tmux is a thin fzf wrapper that has only a few more options than fzf
# itself. As a quick improvement we take fzf's completion. Adding the few extra
# fzf-tmux specific options (like `-w WIDTH`) are left as a future patch.
complete -o default -F _fzf_opts_completion fzf-tmux

# Default path completion
__fzf_default_completion() {
  __fzf_generic_path_completion _fzf_compgen_path "-m" "" "$@"

  # Dynamic completion loader has updated the completion for the command
  if [[ $? -eq 124 ]]; then
    # We trigger _fzf_setup_completion so that fuzzy completion for the command
    # still works. However, loader can update the completion for multiple
    # commands at once, and fuzzy completion will no longer work for those
    # other commands. e.g. pytest -> py.test, pytest-2, pytest-3, etc
    _fzf_setup_completion path "$1"
    return 124
  fi
}

# Set fuzzy path completion as the default completion for all commands.
# We can't set up default completion,
# 1. if it's already set up by another script
# 2. or if the current version of bash doesn't support -D option
complete | command grep -q __fzf_default_completion ||
  complete | command grep -- '-D$' | command grep -qv _comp_complete_load ||
  complete -D -F __fzf_default_completion -o default -o bashdefault 2> /dev/null

d_cmds="${FZF_COMPLETION_DIR_COMMANDS-cd pushd rmdir}"

# NOTE: $FZF_COMPLETION_PATH_COMMANDS and $FZF_COMPLETION_VAR_COMMANDS are
# undocumented and subject to change in the future.
#
# NOTE: Although we have default completion, we still need to set up completion
# for each command in case they already have completion set up by another script.
a_cmds="${FZF_COMPLETION_PATH_COMMANDS-"
  awk bat cat code diff diff3
  emacs emacsclient ex file ftp g++ gcc gvim head hg hx java
  javac ld less more mvim nvim patch perl python ruby
  sed sftp sort source tail tee uniq vi view vim wc xdg-open
  basename bunzip2 bzip2 chmod chown curl cp dirname du
  find git grep gunzip gzip hg jar
  ln ls mv open rm rsync scp
  svn tar unzip zip"}"
v_cmds="${FZF_COMPLETION_VAR_COMMANDS-export unset printenv}"

# Preserve existing completion
__fzf_orig_completion < <(complete -p $d_cmds $a_cmds $v_cmds unalias kill ssh 2> /dev/null)

if type _comp_load > /dev/null 2>&1; then
  # _comp_load was added in bash-completion 2.12 to replace _completion_loader.
  # We use it without -D option so that it does not use _comp_complete_minimal as the fallback.
  _fzf_completion_loader=_comp_load
elif type __load_completion > /dev/null 2>&1; then
  # In bash-completion 2.11, _completion_loader internally calls __load_completion
  # and if it returns a non-zero status, it sets the default 'minimal' completion.
  _fzf_completion_loader=__load_completion
elif type _completion_loader > /dev/null 2>&1; then
  _fzf_completion_loader=_completion_loader
fi

__fzf_defc() {
  local cmd func opts REPLY
  cmd="$1"
  func="$2"
  opts="$3"
  if __fzf_orig_completion_instantiate "$cmd" "$func"; then
    eval "$REPLY"
  else
    eval "complete -F \"$func\" $opts \"$cmd\""
  fi
}

# Anything
for cmd in $a_cmds; do
  __fzf_defc "$cmd" _fzf_path_completion "-o default -o bashdefault"
done

# Directory
for cmd in $d_cmds; do
  __fzf_defc "$cmd" _fzf_dir_completion "-o bashdefault -o nospace -o dirnames"
done

# Variables
for cmd in $v_cmds; do
  __fzf_defc "$cmd" _fzf_var_completion "-o default -o nospace -v"
done

# Aliases
__fzf_defc unalias _fzf_alias_completion "-a"

# Processes
__fzf_defc kill _fzf_proc_completion "-o default -o bashdefault"

# ssh
__fzf_defc ssh _fzf_complete_ssh "-o default -o bashdefault"

unset cmd d_cmds a_cmds v_cmds

_fzf_setup_completion() {
  local kind fn cmd
  kind=$1
  fn=_fzf_${1}_completion
  if [[ $# -lt 2 ]] || ! type -t "$fn" > /dev/null; then
    echo "usage: ${FUNCNAME[0]} path|dir|var|alias|host|proc COMMANDS..."
    return 1
  fi
  shift
  __fzf_orig_completion < <(complete -p "$@" 2> /dev/null)
  for cmd in "$@"; do
    case "$kind" in
      dir) __fzf_defc "$cmd" "$fn" "-o nospace -o dirnames" ;;
      var) __fzf_defc "$cmd" "$fn" "-o default -o nospace -v" ;;
      alias) __fzf_defc "$cmd" "$fn" "-a" ;;
      *) __fzf_defc "$cmd" "$fn" "-o default -o bashdefault" ;;
    esac
  done
}
#----END shfmt

fi
### end: completion.bash ###

# --- carapace init ---
# export PATH="/home/john/.config/carapace/bin:$PATH"

get-env () { echo "${!1}"; }
set-env () { export "$1=$2"; }
unset-env () { unset "$1"; }

_carapace_completer() {
  export COMP_LINE
  export COMP_POINT
  export COMP_TYPE
  export COMP_WORDBREAKS

  declare -x CARAPACE_SHELL=bash
  declare -x CARAPACE_SHELL_ALIASES="$(compgen -a)"
  declare -x CARAPACE_SHELL_BUILTINS="$(compgen -b)"
  declare -x CARAPACE_SHELL_FUNCTIONS="$(compgen -A function)"
  declare -x CARAPACE_SHELL_JOBS="$(jobs 2>/dev/null | while read -r line; do [[ $line =~ \[([0-9]+)\] ]] && echo "%${BASH_REMATCH[1]}"; done)"
  declare -x CARAPACE_SHELL_VARIABLES="$(compgen -v)"

  local command="${COMP_WORDS[0]}" nospace data compline="${COMP_LINE:0:${COMP_POINT}}"

  data=$(echo "${compline}''" | xargs carapace "${command}" bash 2>/dev/null)
  if [ $? -eq 1 ]; then
    data=$(echo "${compline}'" | xargs carapace "${command}" bash 2>/dev/null)
    if [ $? -eq 1 ]; then
    	data=$(echo "${compline}\"" | xargs carapace "${command}" bash 2>/dev/null)
    fi
  fi

  IFS=$'\001' read -r -d '' nospace data <<<"${data}"
  mapfile -t COMPREPLY < <(echo "${data}")
  unset COMPREPLY[-1]

  [ "${nospace}" = true ] && compopt -o nospace
  local IFS=$'\n'
  [[ "${COMPREPLY[*]}" == "" ]] && COMPREPLY=() # fix for mapfile creating a non-empty array from empty command output
}

complete -o noquote -F _carapace_completer "000_bash_completion_compat" "2to3" "5g" "5l" "6g" "6l" "7z" "7za" "7zr" "7zz" "7zzs" "8g" "8l" "Mosaic" "SuSEconfig" "a2dismod" "a2dissite" "a2enmod" "a2ensite" "a2ps" "a2x" "aaaa" "aap" "aapt" "abcde" "abook" "ack" "ack-grep" "ack-standalone" "ack2" "aclocal" "aclocal-1.10" "aclocal-1.11" "aclocal-1.12" "aclocal-1.13" "aclocal-1.14" "aclocal-1.15" "aclocal-1.16" "acpi" "acpid" "acpitool" "acroread" "act" "adb" "add-apt-repository" "add-zle-hook-widget" "add-zsh-hook" "add_members" "admin" "age" "agg" "ali" "alpine" "alsamixer" "alternatives" "amaya" "analyseplugin" "animate" "anno" "ansible" "ansible-config" "ansible-console" "ansible-creator" "ansible-doc" "ansible-galaxy" "ansible-inventory" "ansible-playbook" "ansible-pull" "ansible-vault" "ant" "antiword" "aodh" "aoss" "apache2ctl" "apachectl" "apk" "apko" "apksigner" "aplay" "apm" "appdata-validate" "appletviewer" "apport-bug" "apport-cli" "apport-collect" "apport-unpack" "appstreamcli" "apptainer" "apropos" "apt" "apt-add-repository" "apt-build" "apt-cache" "apt-cdrom" "apt-config" "apt-file" "apt-get" "apt-mark" "apt-move" "apt-show-versions" "aptitude" "aptitude-curses" "apvlv" "aqua" "ar" "arch" "archlinux-java" "arduino-ctags" "arecord" "arena" "argo" "argocd" "aria2c" "arm-koji" "arp" "arping" "arpspoof" "artisan" "asciidoc" "asciidoc.py" "asciidoctor" "asciinema" "ash" "aspell" "at" "atq" "atrm" "attr" "atuin" "augtool" "auto-apt" "autoconf" "autoheader" "automake" "automake-1.10" "automake-1.11" "automake-1.12" "automake-1.13" "automake-1.14" "automake-1.15" "automake-1.16" "autoreconf" "autorpm" "autoscan" "autossh" "autoupdate" "avahi-browse" "avahi-browse-domains" "avahi-resolve" "avahi-resolve-address" "avahi-resolve-host-name" "avctrl" "avdmanager" "awk" "aws" "axi-cache" "az" "b2sum" "badblocks" "baobab" "barbican" "base32" "base64" "basename" "basenc" "bash" "bash-language-server" "bat" "batcat" "batch" "batdiff" "batgrep" "batman" "bats" "baz" "bazel" "bc" "beadm" "beep" "benthos" "bibtex" "bison" "bk" "black" "blkdiscard" "blkid" "blockdev" "bloop" "bluetoothctl" "bmake" "bogofilter" "bogotune" "bogoutil" "boundary" "bpftool" "bpftrace" "bpython" "bpython-gtk" "bpython-urwid" "bpython2" "bpython2-gtk" "bpython2-urwid" "bpython3" "bpython3-gtk" "bpython3-urwid" "brctl" "brew" "brotli" "bru" "bsdconfig" "bsdgrep" "bsdinstall" "bsdtar" "btdownloadcurses" "btdownloadcurses.py" "btdownloadgui" "btdownloadgui.py" "btdownloadheadless" "btdownloadheadless.py" "btlaunchmany" "btlaunchmanycurses" "btmakemetafile" "btop" "btreannounce" "btrename" "btrfs" "bts" "btshowmetainfo" "bttrack" "bug" "buildctl" "buildhash" "bun" "bunx" "bunzip2" "burst" "busctl" "but" "bwrap" "bzegrep" "bzfgrep" "bzgrep" "bzip2" "bzip2recover" "bzr" "c++" "cabal" "caffeinate" "cal" "calendar" "calibre" "cancel" "capslock" "carapace" "cardctl" "cargo" "cargo-clippy" "cargo-fmt" "cargo-metadata" "cargo-rm" "cargo-set-version" "cargo-upgrade" "cargo-watch" "carton" "cat" "catchsegv" "cc" "ccache" "ccal" "ccze" "cdbs-edit-patch" "cdc" "cdcd" "cdebug" "cdr" "cdrdao" "cdrecord" "ceilometer" "cekit" "certtool" "cfagent" "cfdisk" "cfrun" "cftp" "chage" "change_pw" "charm" "chattr" "chcon" "chcpu" "chdman" "check_db" "check_perms" "checksec" "cheese" "chezmoi" "chflags" "chfn" "chgrp" "chimera" "chkconfig" "chkstow" "chmod" "choom" "chown" "chpass" "chpasswd" "chroma" "chrome" "chromium" "chromium-browser" "chronyc" "chroot" "chrpath" "chrt" "chsh" "ci" "cifsiostat" "cinder" "ciptool" "circleci" "civclient" "civserver" "ckeygen" "cksfv" "cksum" "clamav-config" "clamav-milter" "clambc" "clamconf" "clamd" "clamdscan" "clamdtop" "clamonacc" "clamscan" "clamsubmit" "clang" "clang++" "clay" "cleanarch" "clear" "clion" "clisp" "clone_member" "cloud-init" "cloudkitty" "clusterdb" "clzip" "cmp" "cmus" "co" "code" "code-insiders" "codecov" "codex" "col" "colcrt" "colima" "colormake" "colormgr" "colrm" "column" "comb" "combine" "combinediff" "comm" "comp" "compare" "composer" "composer.phar" "composite" "compress" "conch" "conda" "conda-content-trust" "conda-env" "config.status" "config_list" "configure" "conjure" "conky" "consul" "convert" "coreadm" "coredumpctl" "cosign" "cowsay" "cowthink" "cp" "cpan2dist" "cpio" "cplay" "cppcheck" "cpupower" "crc" "createdb" "createuser" "crontab" "crsh" "crush" "cryptdisks_start" "cryptdisks_stop" "cryptsetup" "cscope" "csh" "csplit" "cssh" "csup" "csview" "ctags" "ctags-exuberant" "ctags-universal" "cu" "cue" "cura" "curl" "cut" "cvs" "cvsps" "cvsup" "cygcheck" "cygcheck.exe" "cygpath" "cygpath.exe" "cygrunsrv" "cygrunsrv.exe" "cygserver" "cygserver.exe" "cygstart" "cygstart.exe" "d2" "dagger" "dak" "darcs" "darktable" "darktable-cli" "dart" "dash" "datagrip" "dataspell" "date" "dbt" "dbus-launch" "dbus-monitor" "dbus-send" "dc" "dchroot" "dchroot-dsa" "dconf" "dcop" "dcopclient" "dcopfind" "dcopobject" "dcopref" "dcopstart" "dcut" "dd" "deadcode" "debchange" "debcheckout" "debconf" "debconf-show" "debdiff" "debfoster" "deborphan" "debsign" "debsnap" "debuild" "defaults" "deja-dup" "delta" "deno" "designate" "desktop-file-validate" "devbox" "devcontainer" "devlink" "devpod" "devtodo" "df" "dfc" "dfutool" "dhclient" "dhclient3" "dhcpinfo" "dict" "diff" "diff3" "diffstat" "dig" "dillo" "dir" "dircmp" "dircolors" "direnv" "dirname" "display" "dist" "dive" "django-admin" "django-admin.py" "dkms" "dladm" "dlocate" "dlv" "dmake" "dmenu" "dmesg" "dmidecode" "dms" "dmypy" "dnf" "dnf-2" "dnf-3" "dngconverter" "dnsmasq" "dnssec-keygen" "dnsspoof" "doas" "docker" "docker-buildx" "docker-compose" "docker-scan" "dockerd" "doctl" "doing" "domainname" "dos2unix" "dosdel" "dosread" "dot" "downgrade" "dpatch-edit-patch" "dpkg" "dpkg-buildpackage" "dpkg-cross" "dpkg-deb" "dpkg-parsechangelog" "dpkg-query" "dpkg-reconfigure" "dpkg-repack" "dpkg-source" "dpll" "dput" "dracut" "drill" "dropbox" "dropdb" "dropuser" "dscverify" "dselect" "dsh" "dsniff" "dtrace" "dtruss" "du" "dumpadm" "dumpdb" "dumpe2fs" "dumper" "dumper.exe" "dupload" "dvibook" "dviconcat" "dvicopy" "dvidvi" "dvipdf" "dvips" "dviselect" "dvitodvi" "dvitype" "dwb" "e2freefrag" "e2label" "eatmydata" "ebook-convert" "ebtables" "ecasound" "ecryptfs-migrate-home" "ed" "edquota" "egrep" "eject" "electron" "elfdump" "elinks" "elvish" "enscript" "entr" "env" "envsubst" "eog" "epdfview" "epsffit" "erb" "espeak" "etags" "ether-wake" "etherwake" "ethtool" "eu-nm" "eu-objdump" "eu-readelf" "eu-strings" "eview" "evim" "evince" "ex" "exa" "exercism" "expand" "explodepkg" "expr" "express" "extcheck" "extractres" "eza" "f77" "f95" "faas-cli" "factor" "faillog" "fakechroot" "fakeroot" "fallocate" "fastboot" "fastfetch" "fbgs" "fbi" "fc-cache" "fc-cat" "fc-conflist" "fc-list" "fc-match" "fd" "fdisk" "feh" "fetch" "fetchmail" "ffmpeg" "ffplay" "ffprobe" "fgrep" "figlet" "file" "file-roller" "filebucket" "filefrag" "filesnarf" "filterdiff" "find" "find_member" "findaffix" "findfs" "findmnt" "finger" "fink" "fio" "firefox" "firefox-esr" "fish" "fixdlsrps" "fixfmps" "fixmacps" "fixpsditps" "fixpspps" "fixscribeps" "fixtpps" "fixwfwps" "fixwpps" "fixwwps" "flac" "flake8" "flatpak" "flex" "flex++" "flipdiff" "flist" "flists" "flock" "flowadm" "flutter" "flyctl" "fmadm" "fmt" "fmttest" "fned" "fnext" "fnm" "fold" "folder" "folders" "foot" "fortune" "forw" "fprev" "fprintd-delete" "fprintd-enroll" "fprintd-list" "fprintd-verify" "free" "freebsd-make" "freebsd-update" "freeciv" "freeciv-gtk2" "freeciv-gtk3" "freeciv-sdl" "freeciv-server" "freeciv-xaw" "freeze" "freezer" "fs_usage" "fsck" "fsfreeze" "fsh" "fstat" "fstrim" "ftp" "ftpd" "function" "fury" "fuser" "fusermount" "fw_update" "fwhois" "fwupdmgr" "fwupdtool" "fzf" "g++" "g++-5" "g++-6" "g++-7" "g++-8" "g4" "g77" "g95" "galeon" "gapplication" "gatsby" "gawk" "gb2sum" "gbase32" "gbase64" "gbasename" "gcat" "gcc" "gcc-5" "gcc-6" "gcc-7" "gcc-8" "gccgo" "gccgo-5" "gccgo-6" "gccgo-7" "gccgo-8" "gchmod" "gchroot" "gcj" "gcksum" "gcl" "gcloud" "gcmp" "gcomm" "gcore" "gcp" "gcut" "gdate" "gdb" "gdbus" "gdctl" "gdd" "gdf" "gdiff" "gdown" "gdu" "geany" "gegrep" "gem" "genaliases" "gendiff" "genisoimage" "genv" "geoiplookup" "geoiplookup6" "get" "get-env" "getafm" "getclip" "getclip.exe" "getconf" "getent" "getfacl" "getfacl.exe" "getfattr" "getmail" "getopt" "gex" "gexpand" "gfgrep" "gfind" "gfmt" "gfold" "gfortran" "gfortran-5" "gfortran-6" "gfortran-7" "gfortran-8" "gftp" "ggetopt" "ggrep" "ggv" "gh" "gh-copilot" "gh-dash" "gh-stack" "ghalint" "ghead" "ghostscript" "ghostty" "ghostview" "gid" "gimp" "ginstall" "gio" "git" "git-abort" "git-alias" "git-archive-file" "git-authors" "git-browse" "git-browse-ci" "git-buildpackage" "git-clang-format" "git-clear" "git-clear-soft" "git-coauthor" "git-cvsserver" "git-extras" "git-info" "git-prompt" "git-receive-pack" "git-shell" "git-standup" "git-unlock" "git-upload-archive" "git-upload-pack" "git-utimes" "gitk" "gitleaks" "gitlint" "gitsign" "gitui" "gjoin" "gkrellm" "gkrellm2" "glab" "glance" "gln" "global" "global-python-argcomplete" "glocate" "glow" "gls" "gm" "gmake" "gmd5sum" "gmkdir" "gmkfifo" "gmknod" "gmktemp" "gmplayer" "gmv" "gnatmake" "gnl" "gnocchi" "gnokii" "gnome-control-center" "gnome-extensions" "gnome-gv" "gnome-keyring" "gnome-keyring-daemon" "gnome-maps" "gnome-mplayer" "gnome-screenshot" "gnome-terminal" "gnumake" "gnumfmt" "gnupod_INIT" "gnupod_addsong" "gnupod_check" "gnupod_search" "gnutls-cli" "gnutls-cli-debug" "gnutls-serv" "go" "go-carpet" "go-tool-asm" "go-tool-buildid" "go-tool-cgo" "go-tool-compile" "go-tool-covdata" "go-tool-cover" "go-tool-dist" "go-tool-doc" "go-tool-fix" "go-tool-link" "go-tool-mockgen" "go-tool-nm" "go-tool-objdump" "go-tool-pack" "gocryptfs" "gocyclo" "god" "gofmt" "goimports" "goland" "golangci-lint" "gomplate" "gonew" "google-chrome" "google-chrome-stable" "gopls" "goreleaser" "goweight" "gparted" "gpasswd" "gpaste" "gpatch" "gpc" "gpg" "gpg-agent" "gpg-zip" "gpg2" "gpgv" "gpgv2" "gphoto2" "gprintenv" "gprof" "gqview" "gradle" "gradlew" "grail" "greadlink" "grep" "grep-excuses" "grepdiff" "gresource" "grm" "grmdir" "groff" "groupadd" "groupdel" "groupmems" "groupmod" "groups" "growisofs" "grpck" "grub" "grub-editenv" "grub-install" "grub-mkconfig" "grub-mkfont" "grub-mkimage" "grub-mkpasswd-pbkdf2" "grub-mkrescue" "grub-probe" "grub-reboot" "grub-script-check" "grub-set-default" "grype" "gs" "gsa" "gsbj" "gsdj" "gsdj500" "gsed" "gseq" "gsettings" "gsha1sum" "gsha224sum" "gsha256sum" "gsha384sum" "gsha512sum" "gshred" "gshuf" "gslj" "gslp" "gsnd" "gsort" "gsplit" "gssdp-device-sniffer" "gssdp-discover" "gst-inspect-1.0" "gst-launch-1.0" "gstat" "gstdbuf" "gstrings" "gstty" "gsum" "gtac" "gtail" "gtar" "gtee" "gtimeout" "gtk4-builder-tool" "gtk4-image-tool" "gtk4-path-tool" "gtk4-rendernode-tool" "gtouch" "gtr" "gtty" "guilt" "guilt-add" "guilt-applied" "guilt-delete" "guilt-files" "guilt-fold" "guilt-fork" "guilt-header" "guilt-help" "guilt-import" "guilt-import-commit" "guilt-init" "guilt-new" "guilt-next" "guilt-patchbomb" "guilt-pop" "guilt-prev" "guilt-push" "guilt-rebase" "guilt-refresh" "guilt-rm" "guilt-series" "guilt-status" "guilt-top" "guilt-unapplied" "gulp" "gum" "guname" "gunexpand" "guniq" "gunzip" "guptime" "gv" "gview" "gvim" "gvimdiff" "gwc" "gwho" "gxargs" "gzegrep" "gzfgrep" "gzgrep" "gzilla" "gzip" "halt" "hardlink" "hatch" "hciattach" "hciconfig" "hcitool" "hcloud" "hd" "hddtemp" "hdiutil" "head" "heat" "helix" "helm" "helmfile" "helmsman" "help" "hexchat" "hexdump" "hid2hci" "hilite" "histed" "host" "hostid" "hostname" "hostnamectl" "hotjava" "hping" "hping2" "hping3" "htop" "htpasswd" "http" "https" "hugetop" "hugo" "hunspell" "hurl" "hwinfo" "hx" "hyperfine" "i3" "i3-scrot" "i3exit" "i3lock" "i3status" "i3status-rs" "ibus" "iceweasel" "icombine" "iconv" "iconvconfig" "id" "idea" "identify" "idn" "ifconfig" "ifdown" "ifquery" "ifstat" "ifstatus" "iftop" "ifup" "ijoin" "img2pdf" "import" "imv" "inc" "includeres" "incus" "inetadm" "influx" "info" "infocmp" "initctl" "initdb" "inject" "inkscape" "inotifywait" "inotifywatch" "inshellisense" "insmod" "install" "install-info" "installpkg" "interdiff" "invoke-rc.d" "ion" "ionice" "iostat" "ip" "ip6tables" "ip6tables-restore" "ip6tables-save" "ipadm" "ipcalc" "ipcmk" "ipcrm" "ipcs" "iperf" "iperf3" "ipfw" "ipkg" "ipmitool" "ipsec" "ipset" "iptables" "iptables-restore" "iptables-save" "ipv6calc" "irb" "iredis" "ironic" "irssi" "isag" "iscsiadm" "isort" "ispell" "isql" "iwconfig" "iwlist" "iwpriv" "iwspy" "jadetex" "jail" "jar" "jarsigner" "java" "javac" "javadoc" "javah" "javap" "javaws" "jdb" "jexec" "jj" "jls" "joe" "join" "jot" "journalctl" "jpegoptim" "jps" "jq" "jshint" "json_xs" "jsonschema" "julia" "just" "k3b" "k3sup" "k6" "k9s" "kak" "kak-lsp" "kcl" "kcov" "kdeconnect-cli" "kdump" "kernel-install" "keystone" "keytool" "kfmclient" "kill" "killall" "killall5" "kioclient" "kiro" "kitten" "kitty" "kldload" "kldunload" "kmod" "kmonad" "knock" "koji" "kompose" "konqueror" "kotlin" "kotlinc" "kpartx" "kpdf" "kplayer" "ksh" "ksh88" "ksh93" "ktlint" "ktrace" "ktutil" "kubeadm" "kubebuilder" "kubectl" "kubeseal" "kustomize" "kvno" "l2ping" "larch" "last" "lastb" "lastlog" "latex" "latexmk" "lazygit" "lbzip2" "ldap" "ldapadd" "ldapcompare" "ldapdelete" "ldapmodify" "ldapmodrdn" "ldappasswd" "ldapsearch" "ldapvi" "ldapwhoami" "ldconfig" "ldconfig.real" "ldd" "lefthook" "less" "lf" "lftp" "lftpget" "lha" "libreoffice" "light" "lightdm" "lighty-disable-mod" "lighty-enable-mod" "lilo" "limactl" "link" "links" "links2" "lintian" "lintian-info" "linux" "lisp" "list_admins" "list_lists" "list_members" "list_owners" "litecli" "lldb" "llvm-g++" "llvm-gcc" "llvm-objdump" "llvm-otool" "ln" "lnav" "lncrawl" "loadkeys" "locale" "locale-gen" "localectl" "localedef" "localsearch" "locate" "logger" "loginctl" "logname" "look" "losetup" "lp" "lpadmin" "lpinfo" "lpoptions" "lpq" "lpr" "lprm" "lpstat" "lrzip" "ls" "lsattr" "lsb_release" "lsblk" "lscfg" "lsclocks" "lscpu" "lsdev" "lsdiff" "lsfd" "lsinitrd" "lsipc" "lsirq" "lslocks" "lslogins" "lslv" "lsmem" "lsmod" "lsns" "lsof" "lspv" "lsscsi" "lsusb" "lsvg" "ltrace" "lua" "lua5.0" "lua5.1" "lua5.2" "lua5.3" "lua5.4" "lua50" "lua51" "lua52" "lua53" "lua54" "luac" "luac5.0" "luac5.1" "luac5.2" "luac5.3" "luac5.4" "luac50" "luac51" "luac52" "luac53" "luac54" "luarocks" "luseradd" "luserdel" "lusermod" "lvchange" "lvcreate" "lvdisplay" "lvextend" "lvm" "lvmdiskscan" "lvreduce" "lvremove" "lvrename" "lvresize" "lvs" "lvscan" "lynx" "lz4" "lz4c" "lz4c32" "lz4cat" "lzcat" "lzip" "lzma" "lzop" "m-a" "mac2unix" "macof" "madison" "magick" "magnum" "mail" "mailmanctl" "mailsnarf" "make" "make-kpkg" "makeinfo" "makepkg" "man" "manage.py" "manila" "mark" "marp" "mat" "mat2" "matlab" "mattrib" "maturin" "mbimcli" "mc" "mcd" "mcomix" "mcookie" "mcopy" "mcrypt" "md2" "md4" "md5" "md5sum" "mdadm" "mdbook" "mdecrypt" "mdel" "mdeltree" "mdfind" "mdir" "mdls" "mdtool" "mdu" "mdutil" "medusa" "meld" "melt" "members" "mencal" "mencoder" "mere" "merge" "mergechanges" "metaflac" "mfiutil" "mformat" "mgv" "mhfixmsg" "mhlist" "mhmail" "mhn" "mhparam" "mhpath" "mhshow" "mhstore" "micro" "micropython" "mii-diag" "mii-tool" "minicom" "minikube" "mistral" "mitmproxy" "mix" "mixerctl" "mkcert" "mkdir" "mkfifo" "mkfs" "mkinitrd" "mkisofs" "mknod" "mksh" "mkshortcut" "mkshortcut.exe" "mkswap" "mktemp" "mktunes" "mkzsh" "mkzsh.exe" "mlabel" "mlocate" "mmcli" "mmd" "mmm" "mmount" "mmove" "mmsitepass" "modinfo" "modprobe" "module" "module-assistant" "mogrify" "mokutil" "molecule" "monasca" "mondoarchive" "monodevelop" "montage" "moosic" "more" "mosh" "mount" "mountpoint" "mousepad" "mozilla" "mozilla-firefox" "mozilla-xremote-client" "mpc" "mplayer" "mplayer2" "mpstat" "mpv" "mr" "mrd" "mread" "mren" "mrsasutil" "msgchk" "msgsnarf" "msynctool" "mt" "mtn" "mtoolstest" "mtr" "mtx" "mtype" "munchlist" "munin-node-configure" "munin-run" "munin-update" "munindoc" "mupdf" "murano" "mush" "mussh" "mutt" "muttng" "mv" "mvim" "mvn" "mx" "mycli" "mypy" "mysql" "mysqladmin" "mysqldiff" "mysqldump" "mysqlimport" "mysqlshow" "n-m3u8dl-re" "namei" "nano" "native2ascii" "nautilus" "nawk" "nc" "ncal" "ncdu" "ncftp" "nedit" "neomutt" "nerdctl" "netcat" "nethogs" "netplan" "netrik" "netscape" "netstat" "networkctl" "networksetup" "neutron" "new" "newgrp" "newlist" "newman" "newrelic" "newusers" "next" "nfpm" "ng" "nginx" "ngrep" "nh" "nice" "nilaway" "nix" "nix-build" "nix-channel" "nix-instantiate" "nix-shell" "nixos-rebuild" "nkf" "nl" "nm" "nmap" "nmblookup" "nmcli" "nocorrect" "node" "nohup" "nomad" "nova" "nox" "npm" "nproc" "ns" "nsenter" "nslookup" "nsupdate" "ntalk" "ntpd" "ntpdate" "nu" "numfmt" "nvim" "nvram" "objdump" "od" "odme" "odmget" "odmshow" "ogg123" "oggdec" "oggenc" "ogginfo" "oh-my-posh" "oksh" "okular" "ollama" "oomctl" "op" "open" "openscad" "openssl" "openstack" "openvpn" "opera" "opera-next" "opkg" "optipng" "opusdec" "opusenc" "opusinfo" "orbctl" "osascript" "osc" "otool" "p4" "p4d" "pack" "pack200" "packer" "packf" "pacman" "pacman-conf" "pacman-db-upgrade" "pacman-key" "pacman-mirrors" "palemoon" "pamac" "pandoc" "parsehdlist" "partx" "paru" "pass" "passwd" "paste" "patch" "pathchk" "patool" "pax" "pbcopy" "pbpaste" "pbuilder" "pbzip2" "pccardctl" "pcmanfm" "pcp-htop" "pcred" "pdf2dsc" "pdf2ps" "pdfattach" "pdfdetach" "pdffonts" "pdfimages" "pdfinfo" "pdfjadetex" "pdflatex" "pdfopt" "pdfseparate" "pdfsig" "pdftex" "pdftexi2dvi" "pdftk" "pdftocairo" "pdftohtml" "pdftopbm" "pdftoppm" "pdftops" "pdftotext" "pdfunite" "pdksh" "pdlzip" "perf" "perl" "perlcritic" "perldoc" "perltidy" "pfctl" "pfexec" "pfiles" "pflags" "pg_config" "pg_ctl" "pg_dump" "pg_dumpall" "pg_isready" "pg_restore" "pg_upgrade" "pgcli" "pgrep" "phing" "php" "phpstorm" "picard" "pick" "picocom" "pidof" "pidstat" "pidwait" "pigz" "pine" "pinef" "pinfo" "ping" "ping4" "ping6" "pinky" "pip" "pipenv" "pipx" "piuparts" "pixi" "pkg" "pkg-config" "pkg-get" "pkg_add" "pkg_create" "pkg_delete" "pkg_info" "pkgadd" "pkgcli" "pkgconf" "pkgin" "pkginfo" "pkgrm" "pkgsite" "pkgtool" "pkill" "plague-client" "pldd" "plutil" "plzip" "pm-hibernate" "pm-is-supported" "pm-powersave" "pm-suspend" "pm-suspend-hybrid" "pmake" "pman" "pmap" "pmcat" "pmdesc" "pmeth" "pmexp" "pmfunc" "pmload" "pmls" "pmpath" "pmvers" "pngcheck" "pngfix" "pnpm" "podgrep" "podman" "podpath" "podtoc" "poff" "policytool" "pon" "portaudit" "portlint" "portmaster" "portsnap" "postalias" "postcat" "postconf" "postfix" "postgres" "postmap" "postmaster" "postqueue" "postsuper" "povray" "powerd" "poweroff" "powerprofilesctl" "powertop" "ppc-koji" "pprof" "pr" "prelink" "present" "prettybat" "prettyping" "prev" "printenv" "prlimit" "pro" "procs" "procstat" "prompt" "protoc" "prove" "prs" "prstat" "prt" "prun" "ps" "ps2ascii" "ps2epsi" "ps2pdf" "ps2pdf12" "ps2pdf13" "ps2pdf14" "ps2pdfwr" "ps2ps" "psbook" "pscale" "pscp" "pscp.exe" "psed" "psig" "psmerge" "psmulti" "psnup" "psql" "psresize" "psselect" "pstack" "pstoedit" "pstop" "pstops" "pstotgif" "pswrap" "ptree" "ptx" "pulumi" "pump" "puppet" "puppetca" "puppetd" "puppetdoc" "puppetmasterd" "puppetqd" "puppetrun" "putclip" "putclip.exe" "pv" "pvchange" "pvcreate" "pvdisplay" "pvmove" "pvremove" "pvs" "pvscan" "pwait" "pwck" "pwd" "pwdx" "pwgen" "pxz" "py.test" "py.test-2" "py.test-3" "pycharm" "pycodestyle" "pydoc" "pydoc3" "pydocstyle" "pyflakes" "pygmentize" "pyhtmlizer" "pylint" "pylint-2" "pylint-3" "pypy" "pypy3" "pyston" "pyston3" "pytest" "pytest-2" "pytest-3" "python" "python2" "python2.7" "python3" "python3.10" "python3.11" "python3.12" "python3.13" "python3.3" "python3.4" "python3.5" "python3.6" "python3.7" "python3.8" "python3.9" "pyvenv" "pyvenv-3.10" "pyvenv-3.11" "pyvenv-3.12" "pyvenv-3.13" "pyvenv-3.4" "pyvenv-3.5" "pyvenv-3.6" "pyvenv-3.7" "pyvenv-3.8" "pyvenv-3.9" "qdbus" "qemu" "qemu-kvm" "qemu-system-i386" "qemu-system-x86_64" "qiv" "qmicli" "qmk" "qpdf" "qrencode" "qrunner" "qtplay" "querybts" "quilt" "quota" "quotacheck" "quotaoff" "quotaon" "qutebrowser" "radvdump" "rails" "rake" "ralsh" "ramalama" "ranger" "ranlib" "rar" "rc" "rcctl" "rclone" "rcp" "rcs" "rcsdiff" "rdesktop" "rdict" "readelf" "readlink" "readprofile" "readshortcut" "readshortcut.exe" "reboot" "rebootin" "redis-cli" "refile" "reindexdb" "reload" "remove_members" "removepkg" "rename" "renice" "repl" "reportbug" "repquota" "reprepro" "resolvconf" "resolvectl" "restart" "restic" "resume-cli" "retawq" "reuse" "rev" "rfcomm" "rfkill" "rg" "rgrep" "rgview" "rgvim" "ri" "rider" "rifle" "ripsecrets" "rlog" "rlogin" "rm" "rmadison" "rmd160" "rmdel" "rmdir" "rmf" "rmic" "rmid" "rmiregistry" "rmlist" "rmm" "rmmod" "route" "rpcdebug" "rpm" "rpm2targz" "rpm2tgz" "rpm2txz" "rpmbuild" "rpmbuild-md5" "rpmcheck" "rpmkeys" "rpmquery" "rpmsign" "rpmspec" "rpmverify" "rrdtool" "rsh" "rsync" "rtcwake" "rtin" "rubber" "rubber-info" "rubber-pipe" "ruby" "ruby-mri" "rubymine" "run-help" "run0" "runuser" "rup" "rusage" "rust-analyzer" "rust-arch" "rust-b2sum" "rust-base32" "rust-base64" "rust-basename" "rust-basenc" "rust-cat" "rust-chcon" "rust-chgrp" "rust-chmod" "rust-chown" "rust-chroot" "rust-cksum" "rust-comm" "rust-coreutils" "rust-cp" "rust-csplit" "rust-cut" "rust-date" "rust-dd" "rust-df" "rust-dir" "rust-dircolors" "rust-dirname" "rust-du" "rust-echo" "rust-env" "rust-expand" "rust-expr" "rust-factor" "rust-false" "rust-fmt" "rust-fold" "rust-groups" "rust-head" "rust-hostid" "rust-hostname" "rust-id" "rust-install" "rust-join" "rust-kill" "rust-link" "rust-ln" "rust-logname" "rust-ls" "rust-md5sum" "rust-mkdir" "rust-mkfifo" "rust-mknod" "rust-mktemp" "rust-more" "rust-mv" "rust-nice" "rust-nl" "rust-nohup" "rust-nproc" "rust-numfmt" "rust-od" "rust-paste" "rust-pathchk" "rust-pinky" "rust-pr" "rust-printenv" "rust-printf" "rust-ptx" "rust-pwd" "rust-readlink" "rust-realpath" "rust-rm" "rust-rmdir" "rust-runcon" "rust-seq" "rust-sha1sum" "rust-sha224sum" "rust-sha256sum" "rust-sha384sum" "rust-sha512sum" "rust-shred" "rust-shuf" "rust-sleep" "rust-sort" "rust-split" "rust-stat" "rust-stdbuf" "rust-stty" "rust-sum" "rust-sync" "rust-tac" "rust-tail" "rust-tee" "rust-test" "rust-timeout" "rust-touch" "rust-tr" "rust-true" "rust-truncate" "rust-tsort" "rust-tty" "rust-uname" "rust-unexpand" "rust-uniq" "rust-unlink" "rust-uptime" "rust-users" "rust-vdir" "rust-wc" "rust-who" "rust-whoami" "rust-yes" "rustc" "rustdoc" "rustrover" "rustup" "rview" "rvim" "rwho" "rxvt" "s2p" "s390-koji" "sact" "sadf" "sahara" "sar" "savecore" "saw" "say" "sbcl" "sbcl-mt" "sbopkg" "sbuild" "sc_usage" "scan" "scc" "sccs" "sccsdiff" "schedtool" "schroot" "scl" "scons" "scp" "screen" "script" "scriptlive" "scriptreplay" "scrot" "scrub" "scselect" "scutil" "sd" "sdkmanager" "sdptool" "seaf-cli" "sed" "semver" "senlin" "seq" "serialver" "serie" "service" "set-env" "setarch" "setfacl" "setfacl.exe" "setfattr" "setpriv" "setquota" "setsid" "setterm" "setxkbmap" "sfdisk" "sftp" "sh" "sha1" "sha1sum" "sha224sum" "sha256" "sha256sum" "sha384" "sha384sum" "sha512" "sha512sum" "sha512t256" "shasum" "shellcheck" "show" "showchar" "showkey" "showmount" "shred" "shuf" "shutdown" "sidedoor" "signify" "singularity" "sisu" "sitecopy" "skein1024" "skein256" "skein512" "skipstone" "slabtop" "slapt-get" "slapt-src" "sleep" "slides" "slitex" "slocate" "slogin" "slrn" "slsa-verifier" "smartctl" "smbcacls" "smbclient" "smbcontrol" "smbcquotas" "smbget" "smbpasswd" "smbstatus" "smbtar" "smbtree" "smit" "smitty" "snap" "snoop" "snownews" "soa" "socket" "sockstat" "soft" "softwareupdate" "sort" "sortm" "spamassassin" "sparc-koji" "speedtest-cli" "split" "splitdiff" "spovray" "sqlite" "sqlite3" "sqsh" "sr" "srptool" "ss" "ssh" "ssh-add" "ssh-agent" "ssh-copy-id" "ssh-keygen" "ssh-keyscan" "sshfs" "sshmitm" "sshow" "st" "star" "starship" "start" "stat" "staticcheck" "status" "stdbuf" "stg" "stop" "stow" "strace" "strace64" "stream" "strings" "strip" "strongswan" "stty" "su" "subl" "sudo" "sudoedit" "sudoreplay" "sulogin" "sum" "supervisorctl" "supervisord" "surfraw" "sv" "svcadm" "svccfg" "svcprop" "svcs" "svg-term" "svgcleaner" "svk" "svn" "svn-buildpackage" "svnadmin" "sw_vers" "swaks" "swanctl" "swaplabel" "swapoff" "swapon" "sway" "swaybar" "swaybg" "swayidle" "swaylock" "swaymsg" "swaynag" "swift" "swiftc" "syft" "sync" "sync_members" "synclient" "sysbench" "sysclean" "sysctl" "sysmerge" "syspatch" "sysrc" "systat" "system_profiler" "systemctl" "systemd-analyze" "systemd-ask-password" "systemd-cat" "systemd-cgls" "systemd-cgtop" "systemd-confext" "systemd-creds" "systemd-cryptenroll" "systemd-delta" "systemd-detect-virt" "systemd-dissect" "systemd-id128" "systemd-inhibit" "systemd-machine-id-setup" "systemd-notify" "systemd-path" "systemd-resolve" "systemd-run" "systemd-sysext" "systemd-tmpfiles" "systemd-tty-ask-password-agent" "systemd-vpick" "sysupgrade" "tac" "tacker" "tail" "talk" "talosctl" "taplo" "tar" "tardy" "task" "taskset" "tc" "tcp_open" "tcpdump" "tcpkill" "tcpnice" "tcptraceroute" "tcsh" "tda" "tdd" "tde" "tdr" "tea" "tee" "telnet" "templ" "termux-apt-repo" "terraform" "terraform-ls" "terragrunt" "terramate" "tesseract" "tex" "texi2any" "texi2dvi" "texi2pdf" "texindex" "tg" "tidy" "tig" "tightvncviewer" "time" "timedatectl" "timeout" "tin" "tinygo" "tinysparql" "tipc" "tkconch" "tkinfo" "tla" "tldr" "tload" "tmate" "tmux" "todo" "todo.sh" "tofu" "toilet" "toit.lsp" "toit.pkg" "toolbox" "top" "tor-browser" "tor-gencert" "tor-print-ed-signing-cert" "tor-resolve" "torsocks" "totdconfig" "touch" "tox" "tpb" "tpkg-debarch" "tpkg-install" "tpkg-install-libc" "tpkg-make" "tpkg-update" "tput" "tqdm" "tr" "trace-cmd" "tracepath" "tracepath6" "traceroute" "traefik" "transmission-cli" "transmission-create" "transmission-daemon" "transmission-edit" "transmission-remote" "transmission-show" "trash" "tree" "trial" "trivy" "trove" "truncate" "truss" "tryaffix" "ts" "tsc" "tsh" "tshark" "tsig-keygen" "tsort" "tty" "ttyd" "tunctl" "tune2fs" "tunes2pod" "turbo" "twidge" "twist" "twistd" "txt" "typst" "ua" "ubuntu-bug" "ubuntu-insights" "ubuntu-report" "uclampset" "udevadm" "udisksctl" "ufw" "ul" "uml_mconsole" "uml_moo" "uml_switch" "umount" "unace" "uname" "unbrotli" "uncompress" "unexpand" "unget" "uniq" "unison" "units" "unix2dos" "unix2mac" "unlink" "unlz4" "unlzma" "unpack" "unpack200" "unpigz" "unrar" "unset-env" "unshare" "unshunt" "unwrapdiff" "unxz" "unzip" "update-alternatives" "update-initramfs" "update-java-alternatives" "update-rc.d" "upgradepkg" "upower" "uptime" "upx" "urlsnarf" "urpme" "urpmf" "urpmi" "urpmi.addmedia" "urpmi.removemedia" "urpmi.update" "urpmq" "urxvt" "urxvt256c" "urxvt256c-ml" "urxvt256c-mlc" "urxvt256cc" "urxvtc" "usbconfig" "uscan" "useradd" "userdbctl" "userdel" "usermod" "users" "uuidd" "uuidgen" "uuidparse" "vacuumdb" "vagrant" "val" "valgrind" "varlinkctl" "vault" "vcs_info_hookadd" "vcs_info_hookdel" "vdir" "vercel" "vgcfgbackup" "vgcfgrestore" "vgchange" "vgck" "vgconvert" "vgcreate" "vgdisplay" "vgexport" "vgextend" "vgimport" "vgmerge" "vgmknodes" "vgreduce" "vgremove" "vgrename" "vgs" "vgscan" "vgsplit" "vhs" "vi" "view" "viewnior" "vigr" "vim" "vim-addons" "vimdiff" "vipw" "virsh" "virt-admin" "virt-host-validate" "virt-pki-validate" "virt-xml-validate" "visudo" "vitrage" "viu" "vivid" "vlc" "vmctl" "vmstat" "vncserver" "vncviewer" "volta" "vorbiscomment" "vpnc" "vpnc-connect" "vserver" "vunnel" "w" "w3m" "wajig" "wall" "wanna-build" "watch" "watcher" "watchexec" "watchgnupg" "waypoint" "wc" "webmitm" "webstorm" "wezterm" "wget" "what" "whatis" "whereis" "which" "whiptail" "who" "whoami" "whois" "whom" "wiggle" "wine" "wine-development" "wine-stable" "wine64" "wine64-development" "wine64-stable" "wineboot" "winepath" "wineserver" "winetricks" "wipefs" "wire" "wireshark" "wishlist" "withlist" "wl-copy" "wl-mirror" "wl-paste" "wodim" "woeusb" "wol" "wpa_cli" "wpctl" "write" "wsimport" "wt" "wtf" "wvdial" "www" "xargs" "xattr" "xauth" "xautolock" "xbacklight" "xbps-alternatives" "xbps-checkvers" "xbps-create" "xbps-dgraph" "xbps-digest" "xbps-fbulk" "xbps-fetch" "xbps-install" "xbps-pkgdb" "xbps-query" "xbps-reconfigure" "xbps-remove" "xbps-rindex" "xbps-uchroot" "xbps-uhelper" "xbps-uunshare" "xclip" "xcode-select" "xdg-mime" "xdg-settings" "xdotool" "xdpyinfo" "xdvi" "xev" "xfd" "xfig" "xfontsel" "xfreerdp" "xgamma" "xh" "xhost" "xinput" "xkill" "xli" "xloadimage" "xlsatoms" "xlsclients" "xml" "xmllint" "xmlstarlet" "xmlwf" "xmms" "xmms2" "xmodmap" "xmosaic" "xon" "xonsh" "xournal" "xpdf" "xping" "xpovray" "xprop" "xrandr" "xrdb" "xscreensaver-command" "xset" "xsetbg" "xsetroot" "xsltproc" "xterm" "xtightvncviewer" "xtp" "xv" "xvfb-run" "xview" "xvnc4viewer" "xvncviewer" "xwd" "xwininfo" "xwit" "xwud" "xxd" "xxhsum" "xz" "xzcat" "xzdec" "yafc" "yarn" "yash" "yast" "yast2" "yay" "yes" "yj" "ykman" "youtube-dl" "ypbind" "ypcat" "ypmatch" "yppasswd" "yppoll" "yppush" "ypserv" "ypset" "ypwhich" "ypxfr" "yt-dlp" "ytalk" "yum" "yum-arch" "yumdb" "zargs" "zathura" "zcalc" "zcat" "zcp" "zdb" "zdelattr" "zdump" "zeal" "zed" "zegrep" "zen" "zf_chmod" "zf_ln" "zf_mkdir" "zf_mv" "zf_rm" "zf_rmdir" "zfgrep" "zfs" "zgetattr" "zgrep" "zig" "zip" "zipinfo" "zlistattr" "zln" "zlogin" "zmail" "zmv" "zone" "zoneadm" "zopfli" "zopflipng" "zoxide" "zpool" "zpty" "zramctl" "zsetattr" "zsh" "zsh-mime-handler" "zsocket" "ztodo" "zun" "zxpdf" "zypper"


# --- starship init ---
eval -- "$(/usr/local/bin/starship init bash --print-full-init)"

