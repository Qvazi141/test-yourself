#!/bin/bash

#
# Bash script for make full and incremental backups
# Usage: add execute permission for script,
#        install & config sendmail,
#        add recipients to script variable $recipients,
#        change $src variable, chage $dst variable,
#        run script
# Parameters:
# Example: ./task_3.sh
# Description:
# Recomendation: Don't use in production envirement.
#

src=./app
dst=./dst/main
archive=./dst/archiev
logFile="./buckup.log"
recipients="test@gmail.com,test2@gmail.com"

writeToLog() {
	echo -e "${1}" | tee -a "$logFile"
}

daily() {
  folder="$(date +%Y-%m-%d)"
  touch "$logFile"

  if rsync -ravzXH --delete --log-file="$logFile" --backup --backup-dir="$folder" --progress "$src" "$dst"
  then
    writeToLog "\\n$(date +%Y/%m/%d) - Backup completed successfully\\n"
  else
    writeToLog "\\n$(date +%Y/%m/%d) - Backup failed, try again later\\n"
  fi
}

check_dirs() {
  if [[ -n $(find $dst -ctime 7 -type d -regex ".*") ]]
  then
    mkdir -p "$archive"
    tar cfz "$archive/$(date +%Y-week%V)".tar.gz $dst &&
    writeToLog "\\n$(date +%Y/%m/%d) - Make weekly archive\\n" &&
    rm -rf "$dst" &&
    writeToLog "\\n$(date +%Y/%m/%d) - Clean main dir\\n" &&
    echo "Clean log file" > "$logFile"
  fi
}

mail() {
  # Mail Template
  subject="Backup"
  body="Backup was creating $(date +%Y/%m/%d)"
  from="test@gmail.com"
  echo -e "Subject:${subject}\n${body}" | sendmail -f "${from}" -t "${recipients}"
}

if [[ -d $src ]]
  then
    mkdir -p "$dst"
    check_dirs
    daily
    if [[ -x $(command -v sendmail) ]]
    then
      mail
      writeToLog "\\n$(date +%Y/%m/%d) - Send mail...\\n"
    else
      writeToLog "\\n$(date +%Y/%m/%d) - Sendmail is not installed"
    fi
  else
    writeToLog "\\n$(date +%Y/%m/%d) - Error: SRC dir not found. Can not continue."
fi
