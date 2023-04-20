#!/bin/bash
IP="$1"
REVERSED_IP=$(echo "$IP" | awk -F. '{OFS="."; print $4, $3, $2, $1}')
BLACKLISTS=(
  "zen.spamhaus.org"
  "bl.spamcop.net"
  "dnsbl.sorbs.net"
  "b.barracudacentral.org"
  "cbl.abuseat.org"
  "dnsbl-1.uceprotect.net"
  "dnsbl-2.uceprotect.net"
  "dnsbl-3.uceprotect.net"
  "db.wpbl.info"
  "dnsbl.dronebl.org"
  "ix.dnsbl.manitu.net"
)

if [ -z "$IP" ]; then
  echo -e "\033[1;31mUsage: $0 <IP address>\033[0m"
  exit 1
fi

IS_CLEAN=1
LISTED_COUNT=0
TOTAL_BLACKLISTS=${#BLACKLISTS[@]}
COLOR_INDEX=0

COLORS=(
  "\033[1;32m" # Green
  "\033[1;33m" # Yellow
  "\033[1;34m" # Blue
  "\033[1;35m" # Magenta
  "\033[1;36m" # Cyan
)

for BLACKLIST in "${BLACKLISTS[@]}"; do
  RESULT=$(dig +short "$REVERSED_IP.$BLACKLIST" A)
  if [ -n "$RESULT" ]; then
    echo -e "${COLORS[$COLOR_INDEX]}The IP $IP is listed on $BLACKLIST.\033[0m"
    IS_CLEAN=0
    LISTED_COUNT=$((LISTED_COUNT + 1))
  fi
  COLOR_INDEX=$(( (COLOR_INDEX + 1) % ${#COLORS[@]} ))
done

if [ "$IS_CLEAN" -eq 1 ]; then
  echo -e "\033[1;32mThe IP $IP is clean (not listed on any checked blacklist).\033[0m"
fi

echo -e "\033[1;37mThe IP $IP is listed on $LISTED_COUNT out of $TOTAL_BLACKLISTS checked blacklists.\033[0m"
