#!/usr/bin/env bash

# colorfg <true-color>
colorfg() {
    # shellcheck disable=SC2059 #:`"\x1b[38;5;%dm" "$1"` wouldn't trigger ansi code
    printf "\x1b[38;5;$1m"
}

# colorbg <true-color>
colorbg() {
    # shellcheck disable=SC2059 #:`"\x1b[48;5;%dm" "$1"` wouldn't trigger ansi code
    printf "\x1b[48;5;$1m"
}

# preset colors
BLACK="$(colorfg 0)" ; LBLACK="$(colorfg 8)"
RED="$(colorfg 1)" ; LRED="$(colorfg 9)"
GREEN="$(colorfg 2)" ; LGREEN="$(colorfg 10)"
YELLOW="$(colorfg 3)" ; LYELLOW="$(colorfg 11)"
BLUE="$(colorfg 4)" ; LBLUE="$(colorfg 12)"
MAGENTA="$(colorfg 5)" ; LMAGENTA="$(colorfg 13)"
CYAN="$(colorfg 6)" ; LCYAN="$(colorfg 14)"
GREY="$(colorfg 7)" ; LGREY="$(colorfg 15)"
RESET="$(printf "\x1b[0m")"

hidecur() {
    printf "\x1b[?25l"
}

showcur() {
    printf "\x1b[?25h"
}

enable_altbuff() {
    printf "\x1b[?1049h"
}

disable_altbuff() {
    printf "\x1b[?1049l"
}

# raw_tell <msg...>
raw_tell() {
    IFS=' ' read -ra words <<< "$@"

    local n=1
    for w in "${words[@]}"; do
        printf " $COLOR$w%s" "$RESET"
        if (( n >= 10 && ${#w} > 3 )); then
            n=1
            echo
        else n="$(( n + 1 ))"; fi
    done
    echo
}

# tell <msg...>
tell() { COLOR="$LYELLOW" raw_tell "$@"; }

# run_cmd <cmd> [args...]
run_cmd() {
    local cmd="$1"; shift

    COLOR="$LBLUE" raw_tell "\$ $cmd $*\n"
    "$cmd" "$@" || {
        COLOR="$RED" raw_tell "Command failed miserably, exit code $?."
        end_p
        on_exit 1
    }
}

end_p() {
    echo
    read -rsp " Press ${LRED}any key$RESET to continue." -N1
    clear
}

# exit handler
on_exit() {
    showcur
    disable_altbuff
    [[ -n "$1" ]] && exit "$1"
}

# SIGINT handler
sigint() {
    clear
    on_exit
    exit 130
}

trap sigint SIGINT

#==================================================================#

enable_altbuff; hidecur # start the magic 🪄
clear

p1() {
    echo

    for c in {9..15}; do
        # shellcheck disable=SC2059 #: no, i want ansi codes to work
        printf -- "  <[ $(colorfg "$c")S T A R T M U X$RESET ]>\r"
        sleep .07
        # shellcheck disable=SC2059 #: same as above
        printf -- "  <[ $(colorfg "$(( c - 7 ))")S T A R T M U X$RESET ]>\r"
        sleep .07
    done; echo $'\n'

    tell "Welcome to ${BLUE}Startmux$LYELLOW, you're currently running an interactive setup that helps you getting started with ${LBLACK}Termux$RESET!"
}

p2() {
    echo

    tell "The essential things to do after installing Termux is to run" \
         "$LBLUE'termux-change-repo'$LYELLOW, $LBLUE'pkg update'$RESET and" \
         "$LBLUE'pkg upgrade'.\n"

    tell "But since you're running in a setup, we'll do it for you."

    for sec in {3..1..-1}; do
        printf " ${LYELLOW}Running essential commands in $BLUE%d$LYELLOW...$RESET\r" "$sec"
        sleep 1
    done; echo

    run_cmd termux-change-repo
    run_cmd pkg update
    run_cmd pkg upgrade -y
}
    

# main section
p1; end_p
p2; end_p

on_exit
