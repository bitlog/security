#!/bin/bash


# check gpg config file

GPGCONF="${HOME}/.gnupg/gpg.conf"

if [[ ! -f "${GPGCONF}" ]]; then
  echo -e "\n${GPGCONF} not found\n"
  exit 1
fi


# check gpg values

DEFAULTKEY="0x$(grep "^default-key " ${GPGCONF} | awk '{print $2}')"
KEYSERVERS="$(grep "^keyserver " ${GPGCONF} | awk '{print $2}')"

if [[ -z "${DEFAULTKEY}" ]] || [[ -z "${KEYSERVERS}" ]]; then
  echo -e "\nNo 'default-key' or 'keyserver' defined in ${GPGCONF}\n"
  exit 1
fi


# send gpg keys

for i in ${KEYSERVERS}; do
  gpg --keyserver ${i} --send-keys ${DEFAULTKEY}
done


# exit

exit $?
