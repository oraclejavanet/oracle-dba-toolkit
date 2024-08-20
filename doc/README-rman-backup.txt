================================================================================
                     Oracle Recovery Manager (RMAN) Backup
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Overview
    [*] Notes
    [*] Prerequisites
    [*] Known Issues
    [*] Oracle Real Application Clusters (RAC)
    [*] Create Recovery Catalog
    [*] RMAN Backup Types
    [*] RMAN Validate

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

Use the "bin/rman-backup.sh" shell script to perform regular physical backups of
an Oracle database using Oracle Recovery Manager (RMAN).

--------------------------------------------------------------------------------
Notes
--------------------------------------------------------------------------------

1.  The Oracle RMAN backup script supports both the Oracle multitenant and
    non-multitenant architecture.

2.  The Oracle RMAN backup script is compatible with Oracle Real Application
    Clusters (RAC) and Oracle Automatic Storage Management (ASM).

3.  The Oracle RMAN backup script always generates a dated log file in the log
    directory using the format
    log/rman-backup-{HOSTNAME}-{DATABASE}-{YYYYMMDDHHMISS}.log. This log file
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

4.  The Oracle RMAN backup script provides the capabilities to perform full
    database backups (default) and more granule backups such as incremental and
    archivelog which only backs up the archived redo logs. Specify the type of
    backup using the '-t, --type=<backup-type>' option where <backup-type>
    must be 'full', 'incremental' or 'archivelog'.

5.  Use the '--backup-dir=<backup-dir>' to specify an alternative directory for
    the backup, bypassing the Fast Recovery Area (FRA). When this option is
    used, backups will be stored in the specified directory instead of the
    default FRA location. Backups are stored in the FRA by default, as defined
    by the Oracle instance parameter 'db_recovery_file_dest'.

6.  To make customized changes to the Oracle RMAN backup script, feel free to
    make modifications to the script function "perform_rman_backup()".

--------------------------------------------------------------------------------
Prerequisites
--------------------------------------------------------------------------------

1.  Oracle Database 12c (12.1) or higher.

2.  This script can only authenticate to the target database using an Oracle
    auto login (local) wallet or an Oracle database authentication options file.
    Passing access credentials such as username/password on the command line is
    not supported.

    See: doc/README-oracle-database-authentication.txt

3.  This script requires the database user performing the Oracle RMAN backup
    to have the SYSDBA privilege on the target database to execute successfully.

4.  This script cannot be executed as root.

--------------------------------------------------------------------------------
Known Issues
--------------------------------------------------------------------------------

None at this time.

--------------------------------------------------------------------------------
Oracle Real Application Clusters (RAC)
--------------------------------------------------------------------------------

When running the Oracle RMAN backup script on Oracle RAC, take into
consideration the following critical aspects and requirements.

1.  Oracle RMAN backup fails with ORA-00245.

    Symptoms

    The Oracle RMAN backup fails with the error:

        RMAN-00571: ===========================================================
        RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
        RMAN-00571: ===========================================================
        RMAN-03009: failure of Control File and SPFILE Autobackup command on c1 channel at 04/23/2024 16:49:25
        ORA-00245: control file backup failed; in Oracle RAC, target might not be on shared storage

    Cause

    This is a common error on Oracle RAC with the default value of the
    "SNAPSHOT CONTROLFILE NAME" location.

    This is not a problem with the database control file location, but with the
    location of the snapshot controlfile in Oracle RAC.

    When you need to backup or resynchronize from the control file using Oracle
    RMAN, it first creates a snapshot or consistent image of the control file.
    The copy that is created must reside on a shared location.

    Reason

    Starting with Oracle RAC 11g Release 2 onwards, changes were made to the
    controlfile backup mechanism where any instance in the cluster may write to
    the snapshot controlfile. Because of this, the snapshot controlfile needs to
    be visible to all instances in the Oracle RAC. If the snapshot controlfile
    is not available or not shared, Oracle RMAN will throw such errors during
    backup operation.
    
    Solution

    Configure the snapshot controlfile to a shared disk such as Oracle ACFS
    (Advanced Cluster File System) or an Oracle ASM disk group.
    
    For example:

        RMAN> show snapshot controlfile name;
        
        RMAN configuration parameters for database with db_unique_name CDB are:
        CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/snapcf_cdb1.f'; # default
        
        RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/CDB/CONTROLFILE/snapcf_cdb.f';

        new RMAN configuration parameters:
        CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/CDB/CONTROLFILE/snapcf_cdb.f';
        new RMAN configuration parameters are successfully stored

--------------------------------------------------------------------------------
Create Recovery Catalog
--------------------------------------------------------------------------------

+----------+
| Synopsis |
+----------+

How to create an Oracle RMAN recover catalog database.

+-------------------------------------------------+
| Create an Oracle RMAN Recovery Catalog Database |
+-------------------------------------------------+

1.  Create a new Oracle database named CATDB.

2.  Create a new tablespace named RMAN_CATALOG in the recovery catalog database
    CATDB to store the recovery catalog:
 
    SQL> create tablespace rman_catalog
         datafile size 100m autoextend on next 100m maxsize unlimited
         extent management local uniform size 1m
         segment space management auto;

3.  Create a new database user named RMAN with a default tablespace of
    RMAN_CATALOG.

    SQL> create user rman identified by &rman_password
         default tablespace rman_catalog
         temporary tablespace temp
         quota unlimited on rman_catalog;

4.  Grant the RECOVERY_CATALOG_OWNER role to the new schema owner.

    SQL> grant recovery_catalog_owner to rman;

5.  Create the catalog tables with the RMAN CREATE CATALOG command.

    $ rman catalog rman/rman_pwd@catdb

    connected to recovery catalog database

    RMAN> create catalog tablespace rman_catalog;

    recovery catalog created

+---------------------------------------------+
| Register a Database in the Recovery Catalog |
+---------------------------------------------+

The first step in using a recovery catalog with a target database is registering
the target database in the recovery catalog.

Note: When using a catalog in a Data Guard environment, then you can only
      register the primary database in this way.

1.  Start RMAN and connect to a target database and recovery catalog. The
    recovery catalog database must be open.

    $ rman target dbadmin/dbadmin_pwd catalog rman/rman_pwd@catdb

2.  If the target database is not mounted, then mount or open it:

    RMAN> startup mount;

3.  Register the target database in the connected recovery catalog. RMAN creates
    rows in the catalog tables to contain information about the target database,
    then copies all pertinent data about the target database from the control
    file into the catalog, synchronizing the catalog with the control file.

    RMAN> register database;

4.  Verify that the registration was successful by running REPORT SCHEMA.

    RMAN> report schema;

+-----------------------------------------------+
| Unregister a Database in the Recovery Catalog |
+-----------------------------------------------+

In this example, it is assumed that the target database has been dropped and
you are connecting to the catalog only:

1.  Connect to the catalog (only):

    $ rman catalog /@catdb

2.  List registered databases:

    RMAN> list db_unique_name all;

    List of Databases
    DB Key  DB Name  DB ID            Database Role    Db_unique_name
    ------- ------- ----------------- ---------------  ------------------
    91664   MDB1    250536137         PRIMARY          MDB1
    3687    MPROD   1116716259        PRIMARY          MPROD
    1       APPDB   3454423689        PRIMARY          APPDB
    1589    APDEV   3504941004        PRIMARY          APDEV

    RMAN> list incarnation of database mdb1;

    List of Database Incarnations
    DB Key  Inc Key DB Name  DB ID            STATUS  Reset SCN  Reset Time
    ------- ------- -------- ---------------- ------- ---------- ----------
    91664   91665   MDB1     250536137        CURRENT 1          19-MAR-19

3.  Unregister the target database by database name:

    RMAN> unregister database mdb1;
    
    database name is "mdb1" and DBID is 250536137

    Do you really want to unregister the database (enter YES or NO)? YES
    database unregistered from the recovery catalog

4.  Unregister the target database by DBID:

    RMAN> set dbid 3519815400;

    executing command: SET DBID
    database name is "mdb1" and DBID is 250536137

    RMAN> unregister database mdb1;

    database name is "mdb1" and DBID is 250536137

    Do you really want to unregister the database (enter YES or NO)? YES
    database unregistered from the recovery catalog

+--------------------------------------------+
| Cataloging Backups in the Recovery Catalog |
+--------------------------------------------+

If you have data file copies, backup pieces, or archived logs on disk, then you
can catalog them in the recovery catalog with the CATALOG command. When using a
recovery catalog, cataloging older backups that have aged out of the control
file lets RMAN use the older backups during restore operations.

The following commands illustrate this technique:

    RMAN> catalog datafilecopy '/disk1/old_datafiles/01_01_2003/users01.dbf';

    RMAN> catalog archivelog '/disk1/arch_logs/archive1_731.dbf',
                             '/disk1/arch_logs/archive1_732.dbf';

    RMAN> catalog backuppiece '/disk1/backups/backup_820.bkp';

You can also catalog multiple backup files in a directory by using the
CATALOG START WITH command, as shown in the following example:

    RMAN> catalog start with '/disk1/backups/';

RMAN lists the files to be added to the RMAN repository and prompts for
confirmation before adding the backups. Be careful when creating your prefix
with CATALOG START WITH. RMAN scans all paths for all files on disk that begin
with the specified prefix. The prefix is not just a directory name. Using the
wrong prefix can cause the cataloging of the wrong set of files.
 
For example, assume that a group of directories /disk1/backups, 
/disk1/backups-year2003, /disk1/backupsets, /disk1/backupsets/test and so on, 
all contain backup files. The following command catalogs all files in all of
these directories, because /disk1/backups is a prefix for the paths for all of
these directories:

    RMAN> catalog start with '/disk1/backups';

To catalog only backups in the /disk1/backups directory, the correct command is
as follows:

    RMAN> catalog start with '/disk1/backups/';

+-------------------------------------+
| Upgrade the Recovery Catalog Schema |
+-------------------------------------+

Use the UPGRADE CATALOG command to upgrade a recovery catalog schema from an
older version to the version required by the RMAN client.

Usage Notes:

    *   RMAN prompts you to enter the UPGRADE CATALOG command two consecutive
        times to confirm the upgrade. To bypass the additional confirmation
        step, enter the UPGRADE CATALOG command with the NOPROMPT option while
        running it the first time.
    
    *   RMAN permits the command to be run if the recovery catalog is already
        current so that the packages can be re-created if necessary.
        
    *   If an upgrade to a base recovery catalog requires changes to an existing
        virtual private catalog, then RMAN makes these changes automatically the
        next time RMAN connects to that virtual private catalog.

    *   The UPGRADE CATALOG command does not run scripts to perform an upgrade.
        Instead, RMAN sends various SQL DDL statements to the recovery catalog
        to update the recovery catalog schema with new tables, views, columns,
        and so on.

    *   You do not need to upgrade your recovery catalog database to backup a
        higher version of the database, only the recovery catalog schema needs
        to be upgraded.

    *   Every time you apply a PSU to your target database, you need to also
        upgrade the recovery catalog schema.

    *   Your recovery catalog schema version has to be equal or greater than
        your highest database version (including PSU).

    *   The CATALOG SCHEMA must be the highest version of the target databases;
        however, it can reside in a database that is a lower version if you
        choose to not upgrade the database.

RMAN Compatibility Matrix:

In general, the rules of RMAN compatibility are as follows:


    *   The RMAN executable version should be the same as the target database.
        Legal exception combinations are listed in the table below.

    *   The RMAN catalog schema version must be greater than or equal to the
        RMAN executable.
        
    *   The RMAN catalog is backwards compatible with target databases from
        earlier releases.

Target/Auxiliary
Database            RMAN Executable                     Catalog Database    Catalog Schema
------------------- ----------------------------------- ------------------- ---------------------
8.1.7.4             8.1.7.4                             >=8.1.7 < 12C       8.1.7.4
8.1.7.4             8.1.7.4                             >=8.1.7 < 12C       >=9.0.1.4  
9.0.1               9.0.1                               >=8.1.7 < 12c       >= RMAN client version
9.2.0               >=9.0.1.3 and <= Target database    >=8.1.7 < 12C	    >= RMAN client version
10.1.0.5            >=10.1.0.5 and <= Target Database   >=10.1.0.5          >= RMAN client version
10.2.0              >=10.1.0.5 and <= target database   >=10.1.0.5          >= RMAN client version
11.1.0              >=10.1.0.5 and <= target database   >=10.2.0.3 (note 1) >= RMAN client version
11.2.0              >=10.1.0.5 and <= target database   >=10.2.0.3 (note 1) >= RMAN client version
>=12.1.0.x          = target database executable        >=10.2.0.3          >= RMAN client version
18.x                = target database Executable        >=10.2.0.3          >= RMAN client version
19.x                = target database executable        >= 10.2.0.3         >= RMAN client version
20.x                = target database executable        >= 10.2.0.3         >= RMAN client version
21.x                = target database executable        >= 11.2             >= RMAN client version

Steps to upgrade an Oracle recovery catalog schema after performing an upgrade
of the recovery catalog database.

1.  Connect to the catalog (only):

    $ rman catalog rman@catdb

    Recovery Manager: Release 19.0.0.0.0 - Production on Mon Jun 10 13:52:07 2024
    Version 19.23.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    recovery catalog database Password:
    connected to recovery catalog database
    PL/SQL package RMAN.DBMS_RCVCAT version 19.22.00.00. in RCVCAT database is not current
    PL/SQL package RMAN.DBMS_RCVMAN version 19.22.00.00 in RCVCAT database is not current

2.  Upgrade recovery catalog schema to a more current version:

    RMAN> UPGRADE CATALOG;

    recovery catalog owner is RMAN
    enter UPGRADE CATALOG command again to confirm catalog upgrade

    RMAN> UPGRADE CATALOG;

    recovery catalog upgraded to version 19.23.00.00.00
    DBMS_RCVMAN package upgraded to version 19.23.00.00
    DBMS_RCVCAT package upgraded to version 19.23.00.00.

--------------------------------------------------------------------------------
RMAN Backup Types
--------------------------------------------------------------------------------

In Oracle Recovery Manager (RMAN), level options are used to control the
granularity of backups. RMAN provides the flexibility to perform full or
incremental backups based on the specified level. The levels include full 
backup, incremental level 0 backup, and incremental level 1 backup. Here's an
overview of each:

1.  Full Backup:

    - A full backup involves backing up the entire database or a specific
      tablespace.
    - It creates a complete copy of all the specified files, regardless of
      whether the data has changed since the last backup.
    - Full backups are often used as a baseline for recovery and are typically
      more time and resource-intensive compared to incremental backups.
    - A full backup cannot be part of an incremental backup strategy; it cannot
      be the parent for a subsequent incremental backup.

2.  Incremental Level 0 Backup:

    - An incremental level 0 backup is similar to a full backup, as it also
      backs up the entire database or a specific tablespace.
    - The key difference is that an incremental level 0 backup is treated as a
      baseline for subsequent incremental backups.
    - This type of backup is useful for creating a starting point for
      incremental backups and is less resource-intensive than a full backup.

3.  Incremental Level 1 Backup:

    - Incremental level 1 backups only backup the blocks that have been modified
      since the last incremental backup, whether it was a level 0 or level 1
      backup.
    - Level 1 backups are incremental backups that build upon the level 0
      backup. They capture changes made to the database since the last level 0
      or level 1 backup.
    - Level 1 backups are generally faster and require fewer resources than full
      backups because they only copy the changed blocks.

The choice of backup level depends on factors such as the desired level of
granularity, time constraints, and resource availability. Full backups provide a
comprehensive snapshot of the database but may be more resource-intensive.
Incremental backups are more efficient in terms of time and resources, capturing
only changes made since the last backup, but they rely on a baseline (level 0)
backup.

To implement these backups in Oracle RMAN, you would use commands like 'BACKUP
DATABASE', 'BACKUP TABLESPACE', and specify the appropriate level using the
LEVEL clause. For example:

    -- Full Backup
    BACKUP DATABASE;

    -- Incremental Level 0 Backup
    BACKUP INCREMENTAL LEVEL 0 DATABASE;

    -- Incremental Level 1 Backup
    BACKUP INCREMENTAL LEVEL 1 DATABASE;

+--------------------------------+
| About RMAN Incremental Backups |
+--------------------------------+

An incremental backup copies only those data blocks that have changed since a
previous backup. You can use RMAN to create incremental backups of data files,
tablespaces, or the whole database.

By default, RMAN makes full backups. A full backup of a data file includes every
allocated block in the file being backed up. A full backup of a data file can be
an image copy, in which case every data block is backed up. It can also be
stored in a backup set, in which case data file blocks not in use may be
skipped.

A full backup has no effect on subsequent incremental backups. Image copies are
always full backups because they include every data block in a data file. A
backup set is by default a full backup because it can potentially include every
data block in a data file, although unused block compression means that blocks
never used are excluded and, in some cases, currently unused blocks are
excluded.

Note:   A full backup cannot be part of an incremental backup strategy; that is,
        it cannot be the parent for a subsequent incremental backup.

+--------------------------------------+
| About Multilevel Incremental Backups |
+--------------------------------------+

RMAN can create multilevel incremental backups. Each incremental level is
denoted by a value of 0 or 1.

A level 0 incremental backup, which is the base for subsequent incremental
backups, copies all blocks containing data. The only difference between a level
0 incremental backup and a full backup is that a full backup is never included
in an incremental strategy. Thus, an incremental level 0 backup is a full backup
that happens to be the parent of incremental backups whose level is greater than
0.

A level 1 incremental backup can be either of the following types:

    *   A differential incremental backup, which backs up all blocks changed
        after the most recent incremental backup at level 1 or 0

    *   A cumulative incremental backup, which backs up all blocks changed after
        the most recent incremental backup at level 0

Incremental backups are differential by default.

Incremental backups at level 0 can be either backup sets or image copies, but
incremental backups at level 1 can only be backup sets.

Note:   Cumulative backups are preferable to differential backups when recovery
        time is more important than disk space, because fewer incremental
        backups must be applied during recovery.

The size of the backup file depends solely upon the number of blocks modified,
the incremental backup level, and the type of incremental backup (differential
or cumulative).

+----------------------------------------+
| About Differential Incremental Backups |
+----------------------------------------+

In a differential level 1 backup, RMAN backs up all blocks that have changed
since the most recent incremental backup at level 1 (cumulative or differential)
or level 0.

For example, in a differential level 1 backup, RMAN determines which level 1
backup occurred most recently and backs up all blocks modified after that
backup. If no level 1 is available, then RMAN copies all blocks changed since
the base level 0 backup.

If no level 0 backup is available in either the current or parent incarnation,
then the behavior varies with the compatibility mode setting. If compatibility
is >=10.0.0, RMAN copies all blocks that have been changed since the file was
created. Otherwise, RMAN generates a level 0 backup.

Figure 1 Differential Incremental Backups

         |                                  |
         |                                  |<---------------------------------
         |                                  |                        <----      
         |                                  |                   <----           
         |                                  |              <----                
         |                                  |         <----                     
         |                                  |    <----                          
         |                                  |<---                               
         |<---------------------------------|                                   
         |                        <----     |                                   
         |                   <----          |                                   
         |              <----               |                                   
         |         <----                    |                                   
         |    <----                         |                                   
         |<---                              |                                   
         |                                  |                                   
Backup                                                                          
level    0    1    1    1    1    1    1    0    1    1    1    1    1    1    0
                                                                                
Day     Sun  Mon  Tue  Wed  Thu  Fri  Sat  Sun  Mon  Tue  Wed  Thu  Fri  Sat  Sun

In the example shown in Figure 1, the following activity occurs each week:

    *   Sunday

        An incremental level 0 backup backs up all blocks that have ever been in
        use in this database.

    *   Monday through Saturday

        On each day from Monday through Saturday, a differential incremental
        level 1 backup backs up all blocks that have changed since the most
        recent incremental backup at level 1 or 0. The Monday backup copies
        blocks changed since Sunday level 0 backup, the Tuesday backup copies
        blocks changed since the Monday level 1 backup, and so forth.

+--------------------------------------+
| About Cumulative Incremental Backups |
+--------------------------------------+

In a cumulative level 1 backup, RMAN backs up all blocks used since the most
recent level 0 incremental backup in either the current or parent incarnation.

Cumulative incremental backups reduce the work needed for a restore operation by
ensuring that you only need one incremental backup from any particular level.
Cumulative backups require more space and time than differential backups because
they duplicate the work done by previous backups at the same level.

Figure 2 Cumulative Incremental Backups

         |                                  |
         |                                  |<---------------------------------
         |                                  |<----------------------------
         |                                  |<-----------------------           
         |                                  |<------------------                
         |                                  |<-------------                     
         |                                  |<--------                          
         |                                  |<---                               
         |<---------------------------------|                                   
         |<----------------------------     |                                   
         |<-----------------------          |                                   
         |<------------------               |                                   
         |<-------------                    |                                   
         |<--------                         |                                   
         |<---                              |                                   
         |                                  |                                   
Backup                                                                          
level    0    1    1    1    1    1    1    0    1    1    1    1    1    1    0
                                                                                
Day     Sun  Mon  Tue  Wed  Thu  Fri  Sat  Sun  Mon  Tue  Wed  Thu  Fri  Sat  Sun

In the example shown in Figure 2, the following occurs each week:

    *   Sunday

        An incremental level 0 backup backs up all blocks that have ever been in
        use in this database.

    *   Monday - Saturday

        A cumulative incremental level 1 backup copies all blocks changed since
        the most recent level 0 backup. Because the most recent level 0 backup
        was created on Sunday, the level 1 backup on each day Monday through
        Saturday backs up all blocks changed since the Sunday backup.

--------------------------------------------------------------------------------
RMAN Validate
--------------------------------------------------------------------------------

Oracle RMAN provides a feature called "RMAN Validation" that verifies the
integrity and availability of your database backups without actually restoring
them. This feature ensures that all necessary files for a successful restore are
present and usable. It is an essential part of maintaining a robust backup and
recovery strategy.

------------------------
Key Features of Validate
------------------------

    Integrity Check:            It verifies the integrity of backup files,
                                ensuring that they are not corrupted and are
                                readable.
    Availability Check:         It checks that all required backup files are
                                available and can be used for restoration.
    No Actual Restore:          It performs these checks without making any
                                changes to the current state of the database, so
                                it's safe to run on a live production system.
    Early Detection of Issues:  It helps in early detection of potential issues
                                that could cause a restore to fail, allowing you
                                to address them before an actual recovery is
                                needed.

------------------
How Validate Works
------------------

When you use the VALIDATE command, RMAN reads the backup files and performs
checks to ensure that they can be used to restore the database, tablespace,
datafile, control file, or archived redo logs. However, it does not actually
restore the files, leaving your current database state unchanged.

----------------------------------
About Checksums and Corrupt Blocks
----------------------------------

A corrupt block is a block that has been changed so that it differs from what
Oracle Database expects to find.

Block corruptions can be caused by several different failures including, but not
limited to the following:

    * Faulty disks and disk controllers

    * Faulty memory

    * Oracle Database software defects

DB_BLOCK_CHECKSUM is a database initialization parameter that controls the
writing of checksums for the blocks in data files and online redo log files in
the database (not backups). If DB_BLOCK_CHECKSUM is 'TYPICAL', then the database
computes a checksum for each block during normal operations and stores it in the
header of the block before writing it to disk. When the database reads the block
from disk later, it recomputes the checksum and compares it to the stored value.
If the values do not match, then the block is considered corrupt.

By default, the BACKUP command computes a checksum for each block and stores it
in the backup. The BACKUP command ignores the values of DB_BLOCK_CHECKSUM
because this initialization parameter applies to data files in the database, not
backups.

---------------------------------
Oracle RMAN Validate Enhancements
---------------------------------

Prior to Oracle Database 11g, the VALIDATE syntax could only be used to validate
backup related files. In Oracle Database 11g onward, the VALIDATE feature can
also validate datafiles, tablespaces, or the whole database, so you can use it
in place of the BACKUP VALIDATE / RESTORE VALIDATE command.

See section [Validate Commands] below for examples.

-----------------
Validate Commands
-----------------

The main purpose of RMAN validation is to check for corrupt blocks and missing
files. You can also use RMAN to determine whether backups can be restored.

You can use the following RMAN commands to perform validation:

    VALIDATE

    BACKUP ... VALIDATE

    RESTORE ... VALIDATE

Also, you can use the VALIDATE feature for different parts of the database as
needed.

Below are some common VALIDATE commands.

    ----------------------------
    Validate the Entire Database
    ----------------------------

    Checks all the files required to restore the entire database:

    RMAN> VALIDATE DATABASE;

    Prior to Oracle 11g:

    RMAN> RESTORE DATABASE VALIDATE;

    -----------------------------
    Validate Check Logical
    -----------------------------

    By default, the Oracle RMAN validate command only checks for physical
    corruption, not logical corruption. For this, issue the command:

    RMAN> VALIDATE CHECK LOGICAL DATABASE;

    Prior to Oracle 11g:

    RMAN> RESTORE DATABASE VALIDATE CHECK LOGICAL;

    -----------------------------
    Validate Specific Tablespaces
    -----------------------------

    Validate the backups for specific tablespaces:

    RMAN> VALIDATE TABLESPACE 'tablespace_name';

    Replace 'tablespace_name' with the name of the tablespace you want to
    validate. For example:

    RMAN> VALIDATE TABLESPACE users;
    RMAN> VALIDATE CHECK LOGICAL TABLESPACE users;

    Prior to Oracle 11g:
    
    RMAN> RESTORE TABLESPACE users VALIDATE;

    ----------------------------
    Validate Specific Data Files
    ----------------------------

    To validate the backups for specific datafiles, use:

    RMAN> VALIDATE DATAFILE 'datafile';

    Replace 'datafile' with the datafile number or with the name of the
    file you want to validate. For example:

    RMAN> VALIDATE DATAFILE 1;
    RMAN> VALIDATE DATAFILE '+DATA/CDB/DATAFILE/system.260.1120666063';

    RMAN> VALIDATE CHECK LOGICAL DATAFILE 1;
    RMAN> VALIDATE CHECK LOGICAL DATAFILE '+DATA/CDB/DATAFILE/system.260.1120666063';    

    Prior to Oracle 11g:

    RMAN> RESTORE DATAFILE 1 VALIDATE;
    RMAN> RESTORE DATAFILE '+DATA/CDB/DATAFILE/system.260.1120666063' VALIDATE;

    --------------------------------------------------
    Validate Individual Data blockS within a Data File
    --------------------------------------------------

    Check individual data blocks within a data file for corruption.

    RMAN> VALIDATE DATAFILE 'datafile' BLOCK 'block_number';

    Replace 'datafile' with the datafile number or with the name of the file and
    'block_number' with the data block you want to validate. For example:

    RMAN> VALIDATE DATAFILE '+DATA/CDB/DATAFILE/system.260.1120666063' BLOCK 10;

    ---------------------------
    Validate Archived Redo Logs
    ---------------------------

    To validate the backups of all archived redo logs, use:

    RMAN> VALIDATE ARCHIVELOG ALL;

    Prior to Oracle 11g:

    RMAN> RESTORE ARCHIVELOG ALL VALIDATE;

    -------------------------
    Validate the Control File
    -------------------------

    To validate the backup of the control file, use:

    RMAN> RESTORE CONTROLFILE VALIDATE;

    ----------------------------
    Validate Specific Backup Set
    ----------------------------

    Validate specific backup sets.

    RMAN> VALIDATE BACKUPSET 'backupset_number';

    Replace 'backupset_number' with the number of the backup set you want to
    validate. For example:

    RMAN> VALIDATE BACKUPSET 547710;

------------------------
Validating CDBs and PDBs
------------------------

RMAN enables you to validate multitenant container databases (CDBs) and
pluggable databases (PDBs) using the VALIDATE command.

You can also choose to specify a copy number for the backup pieces being
validated for both CDBs and PDBs.

    *   Validating a Whole CDB (and all PDBs)

        The steps to validate a CDB are similar to the ones used to validate a
        non-CDB.

        The only difference is that you must connect to the root as a common
        user with the common SYSBACKUP or SYSDBA privilege. Then, use the
        VALIDATE DATABASE and RESTORE DATABASE VALIDATE commands.

        The following command, when connected to the root, validates the whole
        CDB:

        RMAN> VALIDATE DATABASE;

        The following command validates the root:

        RMAN> VALIDATE DATABASE ROOT;
    
    *   Validating PDBs

        There are multiple methods to validate PDBs.
        
        Use one of the following techniques to validate PDBs:

            *   Connect to the root and use the VALIDATE PLUGGABLE DATABASE or
                RESTORE PLUGGABLE DATABASE VALIDATE command. This enables you to
                validate one or more PDBs.
                
                The following command, when connected to the root, validates the
                PDBs hr_pdb and sales_pdb.

                RMAN> VALIDATE PLUGGABLE DATABASE hr_pdb, sales_pdb;

            *   Connect to the PDB and use the VALIDATE DATABASE and RESTORE
                DATABASE VALIDATE commands to validate only one PDB. The
                commands used here are the same commands that you would use for
                a non-CDB.
                
                The following command, when connected to a PDB, validates the
                restore of the database.

                RMAN> CONNECT TARGET c##dbadmin@soedb
                RMAN> RESTORE DATABASE VALIDATE;

-------------------------------------------
Identify Objects Containing a Corrupt Block
-------------------------------------------

Any block corruptions are visible in the 'V$DATABASE_BLOCK_CORRUPTION' view.
You can identify the objects containing a corrupt block using the following
query:

COLUMN owner        FORMAT A20
COLUMN segment_name FORMAT A30

SELECT DISTINCT
    owner
  , segment_name
FROM
    v$database_block_corruption dbc
    INNER JOIN dba_extents e ON dbc.file# = e.file_id
                                AND
                                dbc.block# BETWEEN e.block_id and e.block_id+e.blocks-1
ORDER BY
    owner
  , segment_name;

---------------
Good References
---------------

    * https://www.oracle-scn.com/rman-restore-validate-a-proactive-health-check/
    * https://gavinsoorma.com.au/knowledge-base/rman-restore-validate-examples/
    * https://oracle-base.com/articles/misc/detect-and-correct-corruption#google_vignette
