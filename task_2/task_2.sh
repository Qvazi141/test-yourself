#!/bin/bash

#
# Bash script for find proccess with most memory usage
# Usage: add execute permission for script,
#        run script
# Example: ./task_2.sh
# Recomendation: Don't use in production envirement.
#


PROCESS_COUNT=15

ps -axo rss,pid,user,command --sort -rss |
head -n $PROCESS_COUNT |
awk 'BEGIN {
   printf "RSS(Gb) RSS(Mb) RSS(Kb) PID User Command\n"
}
{
   printf "%.2f Gb  %.2f Mb  %.2f Kb  %d %s %s\n", 100*$1/1024/1024/100, $1/1024, $1, $2, $3, $4;
}' |
sed '2d'