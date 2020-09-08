# Security

A collection of simple bash scripts intended for daily usage

1. [check-gpg.sh](check-gpg.sh) *Check private PGP keys for upcoming expiration*
   * Checks private PGP keys for upcoming expiration
   * Generate output for when run from terminal as well as for when run from scripts such as Tmux
1. [check-gpg-pub.sh](check-gpg-pub.sh) *Check public PGP keys for upcoming expiration*
   * Checks public PGP keys for upcoming expiration
   * Generate output for when run from terminal as well as for when run from scripts such as Tmux
1. [genpasswd.sh](genpasswd.sh) *Password manager to create reproducible passwords*
   * Master password creates same password every time
   * Generates passwords from files and/or strings
1. [gpg-send.sh](gpg-send.sh) *Send PGP key*
   * Sends default PGP key to all keyservers in GPG config file
1. [gpg-trust.sh](gpg-trust.sh) *Import PGP key and set trust to full*
   * Downloads PGP key if not imported
   * Updates PGP key if already imported
   * Sets trust level to 4 (fully trusted)
