#!/bin/bash


# unset variables to ensure no residual entries
unset MASTERPW
unset PWS


# create functions
function genpasswd() {
 sha512sum | base64 | head -c20
}


# show help text in case of missing arguments
echo
if [[ -z "${@}" ]]; then
  echo -e "$(basename ${0}) is a script to generate reproducible secure passwords\n" >&2
  echo -e "\nRequired:\n" >&2
  echo -e " File path to create a password per line\n" >&2
  echo -e "OR\n" >&2
  echo -e " A string from which to create a password\n" >&2
  echo -e "\nExamples:\n" >&2
  echo -e " $(basename ${0}) \$HOME/passwords # <-- file\n" >&2
  echo -e " $(basename ${0}) \"gmail.com testuser\" # <-- string\n" >&2
  echo -e " $(basename ${0}) \$HOME/passwords \"gmail.com testuser\" amazon.com # <-- combination of file and multiple strings\n" >&2

  exit 1
fi


# get master password
read -s -p "Enter Master password: " MASTERPW ; echo -e "\n"

# check that master password is not empty
if [[ -z "${MASTERPW}" ]]; then
  echo -e "Master password must not be empty!\n"
  exit 1
fi


# go through arguments
for i in "${@}"; do

  # if argument points to a file, read lines from file
  if [[ -f "${i}" ]]; then
    while read line; do
      # keep empty lines in mind
      if [[ -z "${line}" ]]; then
        PWS="${PWS}"$'\n'

      else
        PWS="$(echo -e "${PWS}\n${line}: $(echo ${MASTERPW}\@${line} | genpasswd)")"
      fi
    done < ${i}

  # if argument does not point to a file, create password from argument
  else
    PWS="$(echo -e "${PWS}\n${i}: $(echo ${MASTERPW}\@${i} | genpasswd)")"
  fi

  # add new line for nicer formatting
  PWS="${PWS}"$'\n'
done


# output and format all passwords
echo -e "${PWS}" | column -e -t -s\:


# unset variables to ensure no residual entries
unset MASTERPW
unset PWS


# exit script
exit $?
