#!/bin/bash
declare -r ROOT_UID=0
declare -r E_NOTROOT=87
declare -r E_WRONG_ARGS=85

declare -r VENDOR_OCTETS=("0821ef" "000393" "00a0c6" "00e0fc" "00e0f9")
declare -r RANDOM_OCTET=$(openssl rand -hex 3)

#Check for valid args
#Only valid arg is "debug"
if [ -z "$1" ]
then
  :
else
  if [ "$1" = "debug" ]
  then
    set -x
  else
    echo "Not a valid argument."
    exit $E_WRONG_ARGS
  fi
fi

#Abort if not root
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

#If the interface environment variable isn't set, ask for clarification
if [ -z "${INTERFACE}" ]
then
  echo "Which interface?"
  read -r INTERFACE
fi

CHOSEN_INDEX=$(( RANDOM % 5 ))
CHOSEN_VENDOR="${VENDOR_OCTETS[CHOSEN_INDEX]}"
NEWMAC=$(echo "$CHOSEN_VENDOR$RANDOM_OCTET" | sed 's/\(..\)/\1:/g; s/.$//')
OLDMAC=$( ifconfig "$INTERFACE" | grep ether | awk -F' ' '{print $2}')
$( whereis ifconfig ) "$INTERFACE" ether "$NEWMAC"
echo "$OLDMAC" ">>" "$NEWMAC"
exit 0

