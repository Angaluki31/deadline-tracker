#!/bin/bash
# Deadline tracker with a days-left countdown

file="$HOME/.deadlines.txt"
touch "$file"

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
GRAY="\033[90m"
RESET="\033[0m"

usage() {
  echo "Usage: bash deadlines.sh add <YYYY-MM-DD> <description>"
  echo "       bash deadlines.sh list"
  echo "       bash deadlines.sh done <number>"
  exit 1
}

valid_date() {
  [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [ "$(date -d "$1" +%F 2>/dev/null)" = "$1" ]
}

days_left() {
  local target today
  target=$(date -u -d "$1" +%s)
  today=$(date -u -d "$(date +%F)" +%s)
  echo $(( (target - today) / 86400 ))
}

add_deadline() {
  local when="$1"
  shift
  local what="$*"
  what="${what//|/ }"

  if ! valid_date "$when"; then
    echo "Error: date must be a real date like 2026-12-01"
    exit 1
  fi

  echo "$when|$what" >> "$file"
  sort -o "$file" "$file"
  echo "Added: $when - $what"
}

list_deadlines() {
  if [ ! -s "$file" ]; then
    echo "No deadlines yet. Add one with: bash deadlines.sh add <date> <description>"
    return
  fi

  local n=0 d color label
  while IFS='|' read -r when what; do
    n=$((n + 1))
    d=$(days_left "$when")

    if [ "$d" -lt 0 ]; then
      color=$GRAY;   label="overdue by $((-d)) day(s)"
    elif [ "$d" -eq 0 ]; then
      color=$RED;    label="TODAY"
    elif [ "$d" -le 3 ]; then
      color=$RED;    label="$d day(s) left"
    elif [ "$d" -le 7 ]; then
      color=$YELLOW; label="$d day(s) left"
    else
      color=$GREEN;  label="$d day(s) left"
    fi

    printf "%2d. %s  ${color}%-20s${RESET} %s\n" "$n" "$when" "$label" "$what"
  done < "$file"
}

remove_deadline() {
  local total
  total=$(wc -l < "$file")
  if [[ ! "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt "$total" ]; then
    echo "Error: no deadline number '$1'"
    exit 1
  fi
  local line
  line=$(sed -n "${1}p" "$file")
  sed -i "${1}d" "$file"
  echo "Removed: ${line//|/ - }"
}

case "$1" in
  add)
    shift
    [ $# -lt 2 ] && usage
    add_deadline "$@"
    ;;
  list) list_deadlines ;;
  done) remove_deadline "$2" ;;
  *)    usage ;;
esac