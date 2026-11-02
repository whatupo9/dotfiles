#!/usr/bin/env bash

# Helper: run only if not already running
run() {
    if ! pgrep -f "$1" > /dev/null 2>&1; then
        "$@" &
    fi
}

# Open alacritty
run alacritty
