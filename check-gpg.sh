#!/bin/bash


FILE="/tmp/$(basename ${0})-$(whoami)"


if ! tty -s; then
  if [[ -f "${FILE}" ]]; then
    cat ${FILE}
  fi

  if [[ "$(date '+%M' | sed 's/^0//')" -ne "0" ]]; then
    exit
  fi
fi


DAYS="30"
KEYS="$(gpg -K | grep -E "^sec|^ssb")"


function check_expiry(){
  awk '{print $2}' | awk -F'/' '{print $2}'
}
function create_error(){
  echo -e "\033[01;31mCould not create ${FILE}\033[00m"
  exit 1
}
function delete_error(){
  echo " | GPG ERROR" > ${FILE}
  echo -e "\033[01;31mCould not delete ${FILE}\033[00m"
}
function expiry_format(){
  tr '\n' ', ' | sed 's/,$//'
}


for i in $(seq 0 ${DAYS}); do
  CHECKDATE="$(date -d "+${i} days" '+%Y-%m-%d')"
  EXPIRE="${EXPIRE}$(echo "${KEYS}" | grep "expires: ${CHECKDATE}" | check_expiry)"
done
ALREADY_EXPIRED="$(echo "${KEYS}" | grep "expired: " | check_expiry)"


if [[ ! -z "${EXPIRE}" ]] || [[ ! -z "${ALREADY_EXPIRED}" ]]; then
  if [[ ! -f "${FILE}" ]]; then
    install -m 0600 /dev/null ${FILE} 2> /dev/null || create_error
  fi
  echo " | GPG" > ${FILE} || exit 1

  if tty -s; then
    if [[ ! -z "${EXPIRE}" ]]; then
      EXPIRE="$(echo "${EXPIRE}" | expiry_format)"
      echo -e "GPG keys ${EXPIRE} will expire in the next \033[01;31m${DAYS} days\033[00m!"
    fi

    if [[ ! -z "${ALREADY_EXPIRED}" ]]; then
      ALREADY_EXPIRED="$(echo "${ALREADY_EXPIRED}" | expiry_format)"
      echo -e "GPG keys ${ALREADY_EXPIRED} are \033[01;31malready expired\033[00m!"
    fi
  fi

else
  if [[ -f "${FILE}" ]]; then
    rm ${FILE} 2> /dev/null || delete_error
  fi

  if tty -s; then
    echo "No GPG keys expire in the next ${DAYS} days"
  fi
fi

exit $?
