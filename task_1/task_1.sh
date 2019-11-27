#!/bin/bash

#
# Bash script for find hacking attempts ssh
# Usage: For execute need permission for iptable managment
#        add execute permission for script,
#        run script with PATH_TO_LOG_FILE parameters
# Example: ./task_1.sh test.log
# Description: Script try to find lines like:
#                   Connection closed by invalid user tplink 5.188.10.176 port 43464 [preauth]
#                   error: PAM: Authentication failure for root from 61.177.172.188
#                   error: maximum authentication attempts exceeded for root from 61.177.172.188 port 44714 ssh2 [preauth]
#              counts them, and if counts > $try_count added them to iptables INPUT chain target DROP
#
# Recomendation: Don't use on production envirement.
#

try_count=10 # for task need 10, bit for see result use 4

list=$(grep -E "((.*invalid user.*|.*error).*(\[preauth\]|Authentication failure))" "$1" |
 grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' |
  sort |
   uniq -cd |
    awk -v limit=$try_count '$1 > limit{print $2}')

echo "Found:"
echo "$list"
echo ""
echo "Result:"
for i in $list;
do
  ADDR=$i
  (iptables -L -n | grep  "DROP .* $ADDR .*" > /dev/null && echo "$ADDR Alredy blocked") ||
  (/sbin/iptables -t filter -I INPUT -s "$ADDR" -j DROP && echo "$ADDR Added to iptables DROP rule")
done
