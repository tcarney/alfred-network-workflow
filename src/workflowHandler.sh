#!/bin/bash

RESULTS=()

################################################################################
# Adds a result to the result array
#
# $1 uid
# $2 arg
# $3 title
# $4 subtitle
# $5 icon
# $6 valid
# $7 autocomplete
###############################################################################
addResult() {
  # Omit an empty uid so Alfred keeps the script order instead of learning it
  local UID_ATTR=""
  if [ "$1" != "" ]; then
    UID_ATTR=" uid='$(xmlEncode "$1")'"
  fi
  RESULT="<item$UID_ATTR arg='$(xmlEncode "$2")' valid='$6' autocomplete='$7'><title>$(xmlEncode "$3")</title><subtitle>$(xmlEncode "$4")</subtitle><icon>$(xmlEncode "$5")</icon></item>"
  RESULTS+=("$RESULT")
}

###############################################################################
# Prints the feedback xml to stdout
###############################################################################
getXMLResults() {
  echo "<?xml version='1.0'?><items>"

#  if [ "${#string[@]}" = "0" ]; then
#    echo "<item uid='oftask' arg='-' valid='no'><title>No results found</title><subtitle>Please try another search term</subtitle><icon></icon></item>"
#  fi

  for R in ${RESULTS[*]}; do
    echo "$R" | tr "\n" " "
  done

  echo "</items>"
}

###############################################################################
# Escapes XML special characters with their entities
###############################################################################
xmlEncode() {
  echo "$1" | sed -e 's/&/\&amp;/g' -e 's/>/\&gt;/g' -e 's/</\&lt;/g' -e "s/'/\&apos;/g" -e 's/"/\&quot;/g'
}
