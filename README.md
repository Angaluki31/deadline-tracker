# Deadline Tracker

A command-line deadline tracker written in Bash. It shows a color-coded countdown of the days left for each deadline, sorted by date.

## Usage 

```bash
bash deadlines.sh add 2026-12-01 "Final exam"
bash deadlines.sh list
bash deadlines.sh done 1
```

## Colors

| Color | Meaning |
|-------|---------|
| Green | More than 7 days left |
| Yellow | 4 to 7 days left |
| Red | 3 days or less, or due today |
| Gray | Overdue |

## Where data is stored

Deadlines are saved in `~/.deadlines.txt` in your home folder, so they stay private and are available from any folder.

## Requirements

Bash (Git Bash on Windows)
