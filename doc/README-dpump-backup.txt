================================================================================
                       Oracle Data Pump (Logical) Backup
================================================================================

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

Use the "bin/dpump-backup.sh" shell script to perform regular logical backups of
an Oracle database using Oracle Data Pump.

--------------------------------------------------------------------------------
Notes
--------------------------------------------------------------------------------

1.  The Oracle Data Pump backup script supports both the Oracle multitenant and
    non-multitenant architecture.

2.  The Oracle Data Pump backup script always generates a dated log file in the
    log directory using the format
    log/dpump-backup-{HOSTNAME}-{DATABASE}-{YYYYMMDDHHMISS}.log. This log file
    serves as a comprehensive record of the backup process, capturing detailed
    information such as start and end times, encountered errors, and the overall
    success or failure of the backup operation. The inclusion of the hostname,
    database name, and timestamp in the log file name ensures uniqueness and
    facilitates easy identification and sorting of log files by their creation
    time.
    
    By default, the script also copies this dated log file to a non-dated
    version at the completion of the script for monitoring purposes. The
    non-dated log file is intended for use in monitoring systems or for quick
    reference, as it consistently points to the most recent backup log. This
    helps in tracking the status of the latest backup without needing to search
    through dated log files.
    
    The script includes an option '--no-monitor-log' that can be used to disable
    the creation of the non-dated log file. This option may be needed to reduce
    clutter or when the monitor log file is not required for your specific
    monitoring setup.

3.  Data Pump does not support any CDB-wide operations. Data Pump issues the
    following warning if you are connected to the root or seed database of a
    CDB:

    Warning: Oracle Data Pump operations are not typically needed when connected
             to the root or seed of a container database.

    The above warning should be a dead giveaway. You should NOT put user data in
    the root container.

4.  To make customized changes to the Oracle Data Pump backup script, feel free
    to make modifications to the script function "perform_dpump_backup()".

--------------------------------------------------------------------------------
Prerequisites
--------------------------------------------------------------------------------

1.  Oracle Database 12c (12.1) or higher.

2.  This script can only authenticate to the target database using an Oracle
    auto login (local) wallet or an Oracle database authentication options file.
    Passing access credentials such as username/password on the command line is
    not supported.

    See: doc/README-oracle-database-authentication.txt

3.  The database user performing the Oracle Data Pump backup cannot connect
    using the SYSDBA privilege. Connecting to the target database as SYSDBA is
    not supported.

4.  This script cannot be executed as root.

5.  This script requires an Oracle directory object in the target database for
    both the dump file and log file to execute properly. To execute
    successfully, the script also requires the database user to have read and
    write privileges on the Oracle directory object(s).

    For example, create Oracle directories for the 'datadb' pluggable database
    and grant read / write permissions on the directories to the database user
    pdbadmin:

    a.  Create destination dump file directory

        SQL> !mkdir /u04/app/oracle/oradpump/DATADB
        SQL> ALTER SESSION SET CONTAINER = datadb;
        SQL> CREATE DIRECTORY dpump_dump_dir AS '/u04/app/oracle/oradpump/DATADB';
        SQL> GRANT read,write ON DIRECTORY dpump_dump_dir TO pdbadmin;

    b.  Create destination log file directory

        SQL> !mkdir /opt/oracle-dba-toolkit/log
        SQL> ALTER SESSION SET CONTAINER = datadb;
        SQL> CREATE DIRECTORY dpump_log_dir AS '/opt/oracle-dba-toolkit/log';
        SQL> GRANT read,write ON DIRECTORY dpump_log_dir TO pdbadmin;

--------------------------------------------------------------------------------
Known Issues
--------------------------------------------------------------------------------

1.  ORA-01031: insufficient privileges

    -----------------
    Error Description
    -----------------

    Export fails with the following "insufficient privileges":

    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/STATISTICS/TABLE_STATISTICS
    ORA-39127: unexpected error from call to local_str := <...>
    ORA-01031: insufficient privileges
    ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 257
    ORA-06512: at line 1
    ORA-06512: at "SYS.DBMS_METADATA", line 4770
    ORA-39127: unexpected error from call to local_str := <...>
    ORA-01031: insufficient privileges
    ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 257
    ORA-06512: at line 1
    ORA-06512: at "SYS.DBMS_METADATA", line 4770
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/DOMAIN_INDEX/INDEX

    This occurs because the user account performing the export lacks the
    "SELECT ANY TABLE" privilege.

    --------------------
    Solution Description
    --------------------
    
    Grant the "SELECT ANY TABLE" privilege to the database user performing the
    export.

    For example:

    SQL> GRANT select any table TO backup_admin;

2.  Oracle Label Security policies

    -----------------
    Error Description
    -----------------

    When using Oracle Label Security policies, the user should have
    "EXEMPT ACCESS POLICY" in order to export all rows in the table, or else no
    rows are exported.

    --------------------
    Solution Description
    --------------------

    SQL> GRANT exempt access policy TO backup_admin;
    
    The Data Pump / Export utility functions in the standard way under
    Oracle Label Security. There are, however, a few differences resulting from
    the enforcement of Oracle Label Security policies.

    a.  For any tables protected by an Oracle Label Security policy, only rows
        with labels authorized for read access will be exported. Unauthorized
        rows will not be included in the export file. Consequently, to export
        all the data in protected tables, you must have a privilege (such as
        FULL or READ) that gives you complete access.

    b.  SQL statements to reapply policies are exported along with tables and
        schemas that are exported. These statements are carried out during
        import to reapply policies with the same enforcement options as in the
        original database.

    c.  The HIDE property is not exported. When protected tables are exported,
        the label columns in those tables are also exported (as numeric values).
        However, if a label column is hidden, then it is exported as a normal,
        unhidden column.

    d.  The LBACSYS schema cannot be exported due to the use of opaque types in
        Oracle Label Security. An export of the entire database
        (parameter FULL=Y) with Oracle Label Security installed can be done,
        except that the LBACSYS schema would not be exported.
