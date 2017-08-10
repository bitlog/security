#!/bin/bash


# check if key is given
if [[ -z "${@}" ]]; then
  echo -e "\nA minimum of one PGP key is required!\n" >&2
  exit 1
fi


# set functions
function gpg_check(){
  gpg -qk | grep -q "${i}"
}


# sort keys
KEYS="$(echo "${@^^}" | tr ' ' '\n' | sed 's/^0X/0x/g' | sort -fu)"

# run through all keys
for i in ${KEYS}; do

  # check if key is valid
  if ! echo "${i}" | grep -q '0x[[:alnum:]]\{16\}$'; then
    echo -e "\n\"${i}\" is not a valid PGP key."

  else
    echo -en "\nPGP key \"${i}\": "

    # download key
    if ! gpg_check; then
      gpg --receive ${i} >/dev/null 2>&1 && echo -n "imported"

    # update key
    else
      gpg --receive ${i} >/dev/null 2>&1 && echo -n "updated"
    fi

    # set trust
    if gpg_check; then
      (echo -e "trust\n4\nquit" | gpg -q --no-tty --command-fd 0 --edit-key ${i} && echo " and fully trusted.") || echo ", but trust could not be set!"

    # if not found, error message
    else
      echo "import failed!"
    fi
  fi
done

# exit
echo
exit $?
