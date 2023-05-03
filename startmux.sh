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

# preset colors
BLACK="$(colorfg 0)"
LBLACK="$(colorfg 8)"
RED="$(colorfg 1)"
LRED="$(colorfg 9)"
GREEN="$(colorfg 2)"
LGREEN="$(colorfg 10)"
YELLOW="$(colorfg 3)"
LYELLOW="$(colorfg 11)"
BLUE="$(colorfg 4)"
LBLUE="$(colorfg 12)"
MAGENTA="$(colorfg 5)"
LMAGENTA="$(colorfg 13)"
CYAN="$(colorfg 6)"
LCYAN="$(colorfg 14)"
GREY="$(colorfg 7)"
LGREY="$(colorfg 15)"
RESET="$(printf "\x1b[0m")"

# tell <msg...>
tell() {
    IFS=' ' read -ra words <<< "$1"

    local n=1
    for w in "${words[@]}"; do
        printf " ${LYELLOW}$w%s$RESET" ""
        if (( n >= 8 && ${#w} > 3 )); then
            n=1
            echo
        else n="$(( n + 1 ))"; fi
    done
    echo
}

end_p() {
    echo
    read -rs -p " Press ${LRED}any key$RESET to continue" -N1
    clear
}

# exit handler
on_exit() {
    showcur
    "$EXIT" || clear
    disable_altbuff
}

trap on_exit SIGINT

#==================================================================#

enable_altbuff; hidecur # start the magic 🪄
clear

p1() {
    echo

    for c in {9..15}; do
        # shellcheck disable=SC2059 #: no, i want ansi codes to work
        printf -- "  -[ $(colorfg "$c")S T A R T M U X $RESET]-\r"
        sleep .1
        # shellcheck disable=SC2059 #: same as above
        printf -- "  -[ $(colorfg "$(( c - 7 ))")S T A R T M U X $RESET]-\r"
        sleep .1
    done; echo $'\n'

    tell "Welcome to ${BLUE}Startmux$RESET$LYELLOW, you're currently running an interactive setup on getting started with ${LBLACK}Termux$RESET!"
}

# main section
p1; end_p


sleep .5
EXIT=true on_exit
