#!/usr/bin/env bash

# +-----------------------------------------------------------------------------
# | File:           rman-backup.sh
# | Database:       Oracle
# | Class:          Backup and Recovery
# | Author:         Jeffrey M. Hunter
# | Description:    The purpose of this script is to perform regular backups of
# |                 an Oracle database using Oracle Recovery Manager (RMAN).
# | Compatibility:  Oracle Database 12c (12.1) or higher.
# |                 Bash version 4 or higher.
# | Coding style:   This script adheres to the Bash Script Style Guide
# |                 published by Google with several exceptions:
# |                 https://google.github.io/styleguide/shellguide.html
# | Requirements:   conf/toolkit-defaults.conf
# |                 functions/lib.sh
# |                 functions/json.sh
# | Documentation:  See: doc/README-rman-backup.txt
# | Authentication: See: doc/README-oracle-database-authentication.txt
# |                 See: doc/README-create-seps-using-oracle-wallet.txt
# | Call syntax:    Use "rman-backup.sh --help" to see the help and options.
# | Example call:   $ rman-backup.sh --db=cdb1 \
# |                                  --sid=cdb1 \
# |                                  --catalog=catdb \
# |                                  --authenticationMethod=wallet \
# |                                  --type=full
# | Repo:           https://gitlab.com/jeffreyhunter/oracle-dba-toolkit
# +-----------------------------------------------------------------------------

#
# Coming Q1 2025
#
