#!/bin/bash

if [ -f ".env" ]; then
    source .env
fi

if [ -z "$SESSION_COOKIE" ]; then
    echo "SESSION_COOKIE environment variable is not set."
    exit 1
fi

fetch_input() {
    local year=$1
    local day=$2

    if wget --spider --header="Cookie: session=${SESSION_COOKIE}" "https://adventofcode.com/${year}/day/${day##0}/input" 2>&1 | grep -q "200 OK"; then
        mkdir -p "./${year}/${day}"
        wget -qO- --header="Cookie: session=${SESSION_COOKIE}" "https://adventofcode.com/${year}/day/${day##0}/input" -O "./${year}/${day}/input.txt"
        echo "Success: Input for year ${year} and day ${day} fetched."
    else
        echo "Error: Input for year ${year} and day ${day} not found (404)."
    fi
}

if [[ $# -eq 1 ]]; then
    if [[ "$1" == "today" ]]; then
        year=$(date +"%Y")
        day=$(date +"%d")
        fetch_input "$year" "${day}"
    fi

    if [[ "$1" == "all" ]]; then
        find . -regextype sed -path './.git' -prune -o -type d -regex './[0-9]\{4\}/[0-9]\{2\}' -print | while IFS= read -r dir; do
            year=$(echo $dir | cut -d'/' -f2)
            day=$(echo $dir | cut -d'/' -f3)
            fetch_input "$year" "${day}"
        done
    fi
fi

if [[ $# -eq 2 ]]; then
    year=$1
    day=$2
    fetch_input "$year" "${day}"
fi
