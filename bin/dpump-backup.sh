#!/usr/bin/env bash

# +-----------------------------------------------------------------------------
# | File:           dpump-backup.sh
# | Database:       Oracle
# | Class:          Backup and Recovery
# | Author:         Jeffrey M. Hunter
# | Description:    The purpose of this script is to perform regular logical
# |                 backups of an Oracle database using Oracle Data Pump.
# | Compatibility:  Oracle Database 12c (12.1) or higher.
# |                 Bash version 4 or higher.
# | Coding style:   This script adheres to the Bash Script Style Guide
# |                 published by Google with several exceptions:
# |                 https://google.github.io/styleguide/shellguide.html
# | Requirements:   conf/toolkit-defaults.conf
# |                 functions/lib.sh
# |                 functions/json.sh
# | Documentation:  See: doc/README-dpump-backup.txt
# | Authentication: See: doc/README-oracle-database-authentication.txt
# |                 See: doc/README-create-seps-using-oracle-wallet.txt
# | Call syntax:    Use "dpump-backup.sh --help" to see the help and options.
# | Example call:   $ dpump-backup.sh --db=datadb \
# |                                   --sid=cdb1 \
# |                                   --authenticationMethod=wallet \
# |                                   --dumpdir=DPUMP_DUMP_DIR \
# |                                   --logdir=DPUMP_LOG_DIR \
# |                                   --retention=2 \
# |                                   --consistent
# | Repo:           https://gitlab.com/jeffreyhunter/oracle-dba-toolkit
# +-----------------------------------------------------------------------------

#
# Coming Q1 2025
#
