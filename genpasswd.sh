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
  echo -e "$(basename ${0}) is a script to generate reproducible secure passwords\n" 1>&2
  echo -e "\nRequired:\n" 1>&2
  echo -e " File path to create a password per line\n" 1>&2
  echo -e "OR\n" 1>&2
  echo -e " A string from which to create a password\n" 1>&2
  echo -e "\nExamples:\n" 1>&2
  echo -e " $(basename ${0}) \${HOME}/passwords # <-- file\n" 1>&2
  echo -e " $(basename ${0}) \"gmail.com testuser\" # <-- string\n" 1>&2
  echo -e " $(basename ${0}) \${HOME}/passwords \"gmail.com testuser\" amazon.com # <-- combination of file and multiple strings\n" 1>&2

  exit 1
fi


# get master password
unset MASTERPW
MASTERPW=""
echo -n 'Enter Master password: ' 1>&2
while IFS= read -r -n1 -s char; do
  case "$( echo -n "${char}" | od -An -tx1 )" in
    '') # EOL
      break
      ;;
    ' 08'|' 7f') # backspace or delete
      if [[ -n "${MASTERPW}" ]]; then
        MASTERPW="$( echo "${MASTERPW}" | sed 's/.$//' )"
        echo -n $'\b \b' 1>&2
      fi
      ;;
    ' 15') # ^U or kill line
      echo -n "${MASTERPW}" | sed 's/./\cH \cH/g' 1>&2
      MASTERPW=''
      ;;
    *)  MASTERPW+="${char}"
      echo -n '*' 1>&2
      ;;
  esac
done
echo -e "\n"

# check that master password is not empty
if [[ -z "${MASTERPW}" ]]; then
  echo -e "\nMaster password must not be empty!\n"
  exit 1
fi


# go through arguments
for i in "${@}"; do

  # if argument points to a file, read lines from file
  if [[ -f "${i}" || -L "${i}" ]]; then
    while read line; do
      # keep empty lines in mind
      if [[ -z "${line}" ]]; then
        PWS+='\n'

      else
        PWS="$(echo -e "${PWS}\n${line}: $(echo ${MASTERPW}\@${line} | genpasswd)")"
      fi
    done < ${i}

  # if argument does not point to a file, create password from argument
  else
    PWS="$(echo -e "${PWS}\n${i}: $(echo ${MASTERPW}\@${i} | genpasswd)")"
  fi

  # add new line for nicer formatting
  PWS+='\n'
done


# output and format all passwords
echo -e "${PWS}" | column -e -t -s\:


# unset variables to ensure no residual entries
unset MASTERPW
unset PWS


# exit script
exit $?
