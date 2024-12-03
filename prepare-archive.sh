#!/usr/bin/env bash

# +-----------------------------------------------------------------------------
# | File name      : prepare-archive.sh
# | Author         : Jeffrey M. Hunter
# | Description    : This script is responsible for creating the deployable
# |                  archive file for the "Oracle DBA Toolkit" project. This
# |                  script must be run from the project repository working
# |                  directory.
# | Prerequisites  : Bash version 4 or higher.
# |                  Linux commands: rsync
# | Known issues   : ERROR: declare: -A: invalid option
# |                     Error Description:
# |                         This script declares an associative array named
# |                         'sql_group'. An associative array in Bash is a data
# |                         structure for storing key-value pairs and first
# |                         appeared in Bash version 4. Old versions of Bash,
# |                         such as the default Bash version on macOS, do not
# |                         support associative arrays.
# |                     Solution Description:
# |                         Use a newer version of Bash that supports
# |                         associative arrays (i.e., Bash version 4 or higher).
# |                         macOS users can install a newer version of Bash with
# |                         Homebrew: 'brew install bash'. Note that in 2023,
# |                         the path changed to '/opt/homebrew/bin/bash'.
# | Example call   : $ cd ~/repos/oracle-dba-toolkit
# |                  $ ./prepare-archive.sh
# | Repo:            https://gitlab.com/jeffreyhunter/oracle-dba-toolkit
# +-----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Import common functions
# ------------------------------------------------------------------------------

# Import all common functions from the functions/ directory
base_path=$(dirname $(realpath $0 | sed 's|\(.*\)|\1|'))
pushd ${base_path} > /dev/null 2>&1
for file in functions/*.sh; do
    source "$file"
done
popd > /dev/null 2>&1
unset base_path file

# Toolkit version
toolkit_version="$(get_toolkit_version ${toolkit_version_file})"
trimmed_string=$(trim "$toolkit_version")
toolkit_version=${trimmed_string}

# ------------------------------------------------------------------------------
# Globally defined script variables
# ------------------------------------------------------------------------------

DEBUG=false

MODULE_NAME="oracle-dba-toolkit"
CURRENT_DIR=$(pwd)
CURRENT_DIR_BASE=${CURRENT_DIR##*/}
CURRENT_DIR_BASE_SQL=${CURRENT_DIR}/sql
STAGING_DIR=/tmp/${MODULE_NAME}
STAGING_DIR_BASE=${STAGING_DIR##*/}
STAGING_DIR_PATH=${STAGING_DIR%/*}
STAGING_SQL_HELP_FILE=$STAGING_DIR/sql/help.sql
ARCHIVE_FILE_NAME="oracle-dba-toolkit-v${toolkit_version}.zip"
HOST_RVAL_SUCCESS=0
HOST_RVAL_WARNING=2
HOST_RVAL_FAILED=2

################################################################################
# main
################################################################################

echo "=============================="
echo "Preparing \"Oracle DBA Toolkit\""
echo "=============================="

echo
echo "[Preflight checks]"
if [ "$CURRENT_DIR_BASE" != "$MODULE_NAME" ]; then
    echo "ERROR: Script must be run from the working directory {git-repository-base}/$MODULE_NAME"
    echo "       Current directory: $CURRENT_DIR"
    exit $HOST_RVAL_FAILED
fi
echo "[ok]"

echo
echo "[Check for rsync command]"
if [ ! -f "/usr/bin/rsync" ]; then
    echo "ERROR: Could not find rsync command"
    exit $HOST_RVAL_FAILED
fi
echo "[ok]"

echo
echo "[Remove previous staging area]"
if [ -d "$STAGING_DIR" ]; then
    echo "Removing existing staging directory: ${STAGING_DIR}"
    rm -rf ${STAGING_DIR}
fi
if [ -f "$STAGING_DIR_PATH/$ARCHIVE_FILE_NAME" ]; then
    echo "Removing existing archive file: $STAGING_DIR_PATH/$ARCHIVE_FILE_NAME"
    rm -f $STAGING_DIR_PATH/$ARCHIVE_FILE_NAME
fi
echo "[ok]"

if [ "$DEBUG" = "true" ]; then
    echo
    echo "[Printing environment variables]"
    echo "CURRENT_DIR:           $CURRENT_DIR"
    echo "CURRENT_DIR_BASE:      $CURRENT_DIR_BASE"
    echo "CURRENT_DIR_BASE_SQL:  $CURRENT_DIR_BASE_SQL"
    echo "STAGING_DIR:           $STAGING_DIR"
    echo "STAGING_DIR_BASE:      $STAGING_DIR_BASE"
    echo "STAGING_DIR_PATH:      $STAGING_DIR_PATH"
    echo "STAGING_SQL_HELP_FILE: $STAGING_SQL_HELP_FILE"
    echo "ARCHIVE_FILE_NAME:     $ARCHIVE_FILE_NAME"
    echo "[ok]"
fi

echo
echo "[Copying repository files]"
rsync -apPq ${CURRENT_DIR}/ ${STAGING_DIR}/
echo "[ok]"

echo
echo "[Generating SQL help file]"
declare -A sql_group
declare -a orders;
echo "-- -----------------------------------------------------------------------------
-- File:       help.sql
-- Database:   Oracle
-- Class:      Database Administration
-- Purpose:    A utility script used to print out the names of all Oracle SQL
--             scripts that can be executed from SQL*Plus.
-- Repo:       https://gitlab.com/jeffreyhunter/oracle-dba-toolkit
-- -----------------------------------------------------------------------------

set linesize  145
set pagesize  9999
set verify    off" > $STAGING_SQL_HELP_FILE

sql_group["asm"]="Automatic Storage Management";            orders+=( "asm" )
sql_group["awr"]="Automatic Workload Repository";           orders+=( "awr" )
sql_group["dg"]="Data Guard";                               orders+=( "dg" )
sql_group["dpump"]="Data Pump";                             orders+=( "dpump" )
sql_group["dba"]="Database Administration";                 orders+=( "dba" )
sql_group["drcp"]="Database Resident Connection Pooling";   orders+=( "drcp" )
sql_group["rsrc"]="Database Resource Manager";              orders+=( "rsrc" )
sql_group["erp"]="Oracle ERP";                              orders+=( "erp" )
sql_group["fra"]="Fast Recovery Area";                      orders+=( "fra" )
sql_group["fdb"]="Flashback Database";                      orders+=( "fdb" )
sql_group["lob"]="LOBs";                                    orders+=( "lob" )
sql_group["locks"]="Locks";                                 orders+=( "locks" )
sql_group["mts"]="Multi Threaded Server";                   orders+=( "mts" )
sql_group["scheduler"]="Oracle Scheduler";                  orders+=( "scheduler" )
sql_group["patch"]="Patch Information";                     orders+=( "patch" )
sql_group["perf"]="Performance Tuning";                     orders+=( "perf" )
sql_group["rman"]="RMAN";                                   orders+=( "rman" )
sql_group["rc"]="RMAN Recovery Catalog";                    orders+=( "rc" )
sql_group["rac"]="Real Application Clusters";               orders+=( "rac" )
sql_group["schema"]="Schema Maintenance";                   orders+=( "schema" )
sql_group["sec"]="Security";                                orders+=( "sec" )
sql_group["sess"]="Session Management";                     orders+=( "sess" )
sql_group["sp"]="Statspack";                                orders+=( "sp" )
sql_group["temp"]="Temporary Tablespace";                   orders+=( "temp" )
sql_group["undo"]="Undo Segments";                          orders+=( "undo" )
sql_group["user"]="User-Level Scripts for Current User";    orders+=( "user" )
sql_group["wm"]="Workspace Manager";                        orders+=( "wm" )

for key in "${orders[@]}"
do
    echo "Working on ${sql_group[$key]}"
    echo "
prompt
prompt ==================================================
prompt ${sql_group[$key]}
prompt ==================================================" >> $STAGING_SQL_HELP_FILE
    for entry in "$STAGING_DIR/sql"/$key*.sql
    do
        if [ -f "$entry" ]; then
        scriptname=${entry##*/}
        echo "    $scriptname"
        echo "prompt $scriptname" >> $STAGING_SQL_HELP_FILE
    fi
    done
done
echo "[ok]"

echo
echo "[Copy SQL help file to repository]"
cp ${STAGING_SQL_HELP_FILE} ${CURRENT_DIR_BASE_SQL}/help.sql
echo "[ok]"

echo
echo "[Remove Git files and temporary files]"
find $STAGING_DIR -type d -name .git -prune -exec rm -rf {} \;
find $STAGING_DIR -name .gitignore -exec rm -f {} \;
find $STAGING_DIR -name .todo -exec rm -f {} \;
find $STAGING_DIR -name PENDING-dba-scripts-headers.txt -exec rm -f {} \;
find $STAGING_DIR -name prepare-archive.sh* -exec rm -f {} \;
find $STAGING_DIR -name _* -exec rm -f {} \;
echo "[ok]"

echo
echo "[Generate archive file]"
(cd $STAGING_DIR_PATH; zip -r $STAGING_DIR_PATH/$ARCHIVE_FILE_NAME $STAGING_DIR_BASE)
echo "[ok]"

echo
echo "[Remove staging area]"
if [ -d "$STAGING_DIR" ]; then
    echo "Removing staging directory: ${STAGING_DIR}"
    rm -rf ${STAGING_DIR}
fi
echo "[ok]"

echo
echo "Created archive file \"$STAGING_DIR_PATH/$ARCHIVE_FILE_NAME\""

echo
echo "Done"
