================================================================================
                      Automatic Workload Repository (AWR)
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Synopsis
    [*] AWR Features
    [*] Snapshot Management and Configuration
    [*] AWR and Oracle Multitenant Database
    [*] Creating and Managing Baselines
    [*] Types of AWR Reports
    [*] SQL Developer and AWR Reports
    [*] Purging Old Snapshots

--------------------------------------------------------------------------------
Synopsis
--------------------------------------------------------------------------------

The Oracle Automatic Workload Repository (AWR) is a built-in repository in
Oracle Database that collects and maintains performance statistics for database
instances. It provides a comprehensive set of performance data that can be used
for analyzing database performance over time.

This note explains how to configure and use AWR to monitor and analyze database
performance in Oracle Database.

The top recommended tasks for configuring Oracle AWR include:

    1.  Setting the appropriate snapshot interval and retention period for
        automatic AWR snapshots.
    
        See: "Snapshot Management and Configuration".

    2.  Enable automatic AWR snapshots for Pluggable Databases (PDBs) in an
        Oracle Multitenant database by setting the dynamic initialization
        parameter AWR_PDB_AUTOFLUSH_ENABLED to true in the root container

        See: "AWR and Oracle Multitenant Database"
    
    3. Creating and managing baselines.

        See: "Creating and Managing Baselines"

--------------------------------------------------------------------------------
AWR Features
--------------------------------------------------------------------------------

The AWR is used to collect performance statistics including:

    * Wait events used to identify performance problems.
    * Time model statistics indicating the amount of DB time associated with a
      process from the V$SESS_TIME_MODEL and V$SYS_TIME_MODEL views.
    * Active Session History (ASH) statistics from the V$ACTIVE_SESSION_HISTORY
      view.
    * Some system and session statistics from the V$SYSSTAT and V$SESSTAT views.
    * Object usage statistics.
    * Resource intensive SQL statements.

The repository is a source of information for several other Oracle features
including:

    * Automatic Database Diagnostic Monitor
    * SQL Tuning Advisor
    * Undo Advisor
    * Segment Advisor

--------------------------------------------------------------------------------
Snapshot Management and Configuration
--------------------------------------------------------------------------------

The "DBMS_WORKLOAD_REPOSITORY" package lets you manage the Automatic Workload
Repository (AWR) by performing operations, such as, managing snapshots and
baselines.

1.  Manually generate a new snapshot for the local database on which the
    subprogram is executed:

        BEGIN
          DBMS_WORKLOAD_REPOSITORY.create_snapshot;
        END;
        /

    Optionally, create a snapshot for the local database with the flush level of
    ALL:

        BEGIN
          DBMS_WORKLOAD_REPOSITORY.create_snapshot('ALL');
        END;
        /

    Note:   Above creates a heavyweight snapshot. All the possible statistics
            are collected. This consumes a considerable amount of disk space and
            takes a long time to create.

2.  By default, snapshots of performance related data are taken every 1 hour
    (60 minutes) and retained for 8 days (7 days retained in Oracle 10g).
    
        COLUMN snapshot_interval_min    FORMAT 999,999,999  HEADING 'Snapshot Interval (min)'
        COLUMN retention_interval_min   FORMAT 999,999,999  HEADING 'Retention Interval (min)'
        COLUMN retention_interval_day   FORMAT 999,999,999  HEADING 'Retention Interval (day)'
        SELECT
            EXTRACT(DAY FROM snap_interval) * 24 * 60 +
            EXTRACT(HOUR FROM snap_interval) * 60 +
            EXTRACT(MINUTE FROM snap_interval)    AS snapshot_interval_min
          , EXTRACT(DAY FROM retention) * 24 * 60 +
            EXTRACT(HOUR FROM retention) * 60 +
            EXTRACT(MINUTE FROM retention)        AS retention_interval_min
          , EXTRACT(DAY FROM retention)           AS retention_interval_day
        FROM
            dba_hist_wr_control;

        Snapshot Interval (min) Retention Interval (min) Retention Interval (day)
        ----------------------- ------------------------ ------------------------
                             60                   11,520                        8
    
    These default settings can be modified for the current database (CDB/PDB)
    using the "DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings" procedure.
    
    For example, change the AWR snapshot interval to every 15 minutes with a
    retention period of 30 days.

        BEGIN
          DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(
            retention => 43200,
            interval  => 15
          );
        END;
        /

--------------------------------------------------------------------------------
AWR and Oracle Multitenant Database
--------------------------------------------------------------------------------

By default, the Oracle database engine automatically takes snapshots in the root
container only (CDB$ROOT). Such snapshots contain performance statistics for the
root container as well as all open PDBs belonging to it. 

From Oracle Database 12.2 onwards, you can control whether the database engine
also automatically takes PDB-level snapshots through the dynamic initialization
parameter AWR_PDB_AUTOFLUSH_ENABLED.

The default value of AWR_PDB_AUTOFLUSH_ENABLED is false. Thus, by default,
automatic AWR snapshots are disabled for all the PDBs in a CDB.

When you change the value of AWR_PDB_AUTOFLUSH_ENABLED in the root container,
the new value takes effect in all the PDBs in the CDB.

Therefore, if you change the value of AWR_PDB_AUTOFLUSH_ENABLED in the root
container to true, the value of AWR_PDB_AUTOFLUSH_ENABLED is also changed to
true in all of the PDBs, so that automatic AWR snapshots are enabled for all
open PDBs belonging to it.

To enable automatic AWR snapshots in the root container and all open PDBs
belonging to it:

    ALTER SESSION SET CONTAINER=cdb$root;
    ALTER SYSTEM SET awr_pdb_autoflush_enabled=true SCOPE=both SID='*';
    SHOW PARAMETER awr_pdb_autoflush_enabled

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- ---------------------------
    awr_pdb_autoflush_enabled            boolean     TRUE

Setting AWR_PDB_AUTOFLUSH_ENABLED to true, performance statistics will be
collected for the root container (CDB$ROOT) and all open PDBs belonging to it as
shown in the following example:

                    +----------------------------------------+
                    | Container Name: CDB$ROOT               |
                    |                                        |
                    |             Snap Id Snap Time          |
                    |             ------- ------------------ |
                    | Begin Snap: 10459   25-May-24 16:03:32 |
                    | End Snap:   10460   25-May-24 16:18:36 |
                    | Elapsed:    15.06 (mins)               |
                    | DB Time:    303.58 (mins)              |
                    +----------------------------------------+
                                      |
                                      |
                +-----------------------------------------------+
                |                                               |
                |                                               |
                |                                               |
+----------------------------------------+  +----------------------------------------+
| Container Name: SOEDB                  |  | Container Name: DATADB                 |
|                                        |  |                                        |
|             Snap Id Snap Time          |  |             Snap Id Snap Time          |
|             ------- ------------------ |  |             ------- ------------------ |
| Begin Snap: 877     25-May-24 16:03:32 |  | Begin Snap: 6964    25-May-24 16:03:32 |
| End Snap:   878     25-May-24 16:18:36 |  | End Snap:   6965    25-May-24 16:18:36 |
| Elapsed:    15.06 (mins)               |  | Elapsed:    15.06 (mins)               |
| DB Time:    285.11 (mins)              |  | DB Time:    18.16 (mins)               |
+----------------------------------------+  +----------------------------------------+

Optionally, manually set the interval and retention period for each PDB.

For example, change the AWR snapshot interval to every 15 minutes with a
retention period of 30 days for a PDB:

    ALTER SESSION SET CONTAINER=pdb1;
    BEGIN
       DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(interval => 15,
                                                         retention => 43200);
    END;
    /

From Oracle Database 18c onwards, use the dynamic initialization parameter
AWR_SNAPSHOT_TIME_OFFSET to configure when the database engine takes automatic
snapshots. With the default value (0), AWR snapshots start at the top of the
hour (12:00, 1:00, 2:00, and so on). For database servers with many database
instances, this can cause CPU spikes if all of them take automatic snapshots at
the same time. Values greater than 0 can help avoiding such an issue.

The AWR_SNAPSHOT_TIME_OFFSET dynamic initialization parameter specifies an
offset for AWR snapshot start time. This parameter allows DBAs to specify an
offset (in seconds) for the AWR snapshot start time. As mentioned earlier, this
is a useful parameter to avoid CPU spikes from multiple instances all starting
their AWR snapshots at the same time. If you have a large system with many
database instances on it, and you are experiencing such CPU spikes, this
parameter can be very useful when set to a value greater than 0.

Typically, you set it to a value less than 3600. If you set the special value
1000000 (1,000,000), you get an "automatic mode", in which the offset is based
on the database name. The automatic mode is an effective way of getting a
reasonable distribution of offset times when you have a very large number of
instances running on the same node.

For example:

    ALTER SESSION SET CONTAINER=cdb$root;
    ALTER SYSTEM SET AWR_SNAPSHOT_TIME_OFFSET=1000000 SCOPE=both SID='*';

Notes about AWR_PDB_AUTOFLUSH_ENABLED:

    * The value of AWR_PDB_AUTOFLUSH_ENABLED in CDB$ROOT (the root of a CDB) has
      no effect in the root. Automatic AWR snapshots are always enabled in the
      root, regardless of the setting of this parameter.

    * The default value of AWR_PDB_AUTOFLUSH_ENABLED is false. Thus, by default,
      automatic AWR snapshots are disabled for all the PDBs in a CDB.

    * When you change the value of AWR_PDB_AUTOFLUSH_ENABLED in the CDB root,
      the new value takes effect in all the PDBs in the CDB.

      Therefore, if you change the value of AWR_PDB_AUTOFLUSH_ENABLED in the
      CDB root to true, the value of AWR_PDB_AUTOFLUSH_ENABLED is also changed
      to true in all of the PDBs, so that automatic AWR snapshots are enabled
      for all the PDBs.

    * You can also change the value of AWR_PDB_AUTOFLUSH_ENABLED in any of the
      individual PDBs in a CDB, and the value that is set for each individual
      PDB will be honored. This enables you to enable or disable automatic AWR
      snapshots for individual PDBs.

      To enable automatic AWR snapshots for a specified PDB:

      SQL> ALTER SESSION SET CONTAINER=pdb1;
      SQL> ALTER SYSTEM SET AWR_PDB_AUTOFLUSH_ENABLED=true;

    * When a new PDB is created, or a PDB from a previous database release is
      upgraded to the current database release, automatic AWR snapshots are
      enabled or disabled for the PDB based on the current value of
      AWR_PDB_AUTOFLUSH_ENABLED in the root.

--------------------------------------------------------------------------------
Creating and Managing Baselines
--------------------------------------------------------------------------------

A baseline is a pair of snapshots that represents a specific period of usage.
Once baselines are defined, they can be used to compare current performance
against similar periods in the past. For example, you may wish to create a
baseline to represent a period of batch processing and another baseline to
represent normal day-to-day transactional workloads. This helps in identifying
trends, detecting anomalies, and ensuring that the database performs optimally
under different workloads.

To create a baseline, employ the CREATE_BASELINE function or procedure from the
DBMS_WORKLOAD_REPOSITORY PL/SQL package.

The following example creates a baseline (named 'OLTP Peakload Baseline') in
the Pluggable Database (PDB) SOEDB between snapshots 1249 and 1257 for the local
database:

    ALTER SESSION SET CONTAINER = soedb;
    BEGIN
      DBMS_WORKLOAD_REPOSITORY.create_baseline (start_snap_id => 1249,
                                                end_snap_id   => 1257,
                                                baseline_name => 'OLTP Peakload Baseline');
    END;
    /

The new baselines are visible in the DBA_HIST_BASELINE view.

    COLUMN container_name       FORMAT a15      HEADING 'Container Name'
    COLUMN baseline_name        FORMAT a35      HEADING 'Baseline Name'
    COLUMN baseline_type        FORMAT a14      HEADING 'Baseline Type'
    COLUMN snap_id_range        FORMAT a15      HEADING 'Snap ID Range'
    COLUMN snap_time_range      FORMAT a20      HEADING 'Snap Time Range'
    COLUMN end_interval_time    FORMAT a20      HEADING 'End Interval Time'
    COLUMN creation_time        FORMAT a20      HEADING 'Creation Date'

    SELECT
        c.name                                                AS container_name
      , h.baseline_name                                       AS baseline_name
      , h.baseline_type                                       AS baseline_type
      , h.start_snap_id || ' - ' || h.end_snap_id             AS snap_id_range
      , TO_CHAR(h.start_snap_time, 'mm/dd/yyyy HH24:MI:SS')
        || CHR(10)
        || TO_CHAR(h.end_snap_time, 'mm/dd/yyyy HH24:MI:SS')  AS snap_time_range
      , TO_CHAR(h.creation_time, 'mm/dd/yyyy HH24:MI:SS')     AS creation_time
    FROM
        dba_hist_baseline h
    JOIN v$containers c ON h.dbid = c.dbid;

    Container Name  Baseline Name                       Baseline Type  Snap ID Range   Snap Time Range      Creation Date
    --------------- ----------------------------------- -------------- --------------- -------------------- --------------------
    SOEDB           OLTP Peakload Baseline              STATIC         1249 - 1257     05/29/2024 11:00:52  05/29/2024 13:25:49
                                                                                       05/29/2024 13:00:00
    SOEDB           SYSTEM_MOVING_WINDOW                MOVING_WINDOW  485 - 1260      05/21/2024 14:03:11  04/05/2023 17:48:02
                                                                                       05/29/2024 13:39:59

The pair of snapshots associated with a baseline are retained until the baseline
is explicitly deleted as shown below:

    BEGIN
      DBMS_WORKLOAD_REPOSITORY.drop_baseline (
        baseline_name => 'OLTP Peakload Baseline',
        cascade       => true);
    END;
    /

Note: Setting CASCADE to true will delete associated snapshots. If CASCADE
      is set to false, it will only drop the baseline (not the snapshots).

--------------------------------------------------------------------------------
Types of AWR Reports
--------------------------------------------------------------------------------

An AWR report outputs a series of statistics based on the differences between
snapshots that may be used to investigate performance and other issues.

This section provides a quick reference to available AWR report scripts
developed and maintained by Oracle Corporation as part of their Oracle Database
software. These scripts are located in the $ORACLE_HOME/rdbms/admin directory
and can be run to generate the corresponding reports.

+-----------------+
| AWR Information |
+-----------------+

$ORACLE_HOME/rdbms/admin/awrinfo.sql    This script will report general AWR
                                        information.

+---------------------+
| General AWR Reports |
+---------------------+

$ORACLE_HOME/rdbms/admin/awrrpt.sql     Generates an AWR report in 'HTML',
                                        'text' or 'active-html' format that
                                        displays statistics from a range of
                                        snapshot IDs in the 'local' database
                                        instance.

$ORACLE_HOME/rdbms/admin/awrrpti.sql    Generates an AWR report in 'HTML',
                                        'text' or 'active-html' format that
                                        displays statistics from a range of
                                        snapshot IDs in a 'specific' database
                                        instance.

+--------------------+
| Oracle RAC Reports |
+--------------------+

$ORACLE_HOME/rdbms/admin/awrgrpt.sql    Generates an AWR report in 'HTML',
                                        'text' or 'active-html' format that
                                        displays statistics from a range of
                                        snapshot IDs in the 'local' database
                                        instance in an Oracle RAC environment.

$ORACLE_HOME/rdbms/admin/awrgrpti.sql   Generates an AWR report in 'HTML',
                                        'text' or 'active-html' format that
                                        displays statistics from a range of
                                        snapshot IDs in a 'specific' database
                                        instance in an Oracle RAC environment.

+-----------------------+
| SQL Statement Reports |
+-----------------------+

$ORACLE_HOME/rdbms/admin/awrsqrpt.sql   Generates an AWR report in 'HTML' or
                                        'text' format that displays statistics
                                        for a particular SQL statement from a
                                        range of snapshot IDs in the 'local'
                                        database instance. You will be prompted
                                        to specify the SQL ID for a specific SQL
                                        statement, allowing for targeted
                                        analysis and performance tuning.

$ORACLE_HOME/rdbms/admin/awrsqrpi.sql   Generates an AWR report in 'HTML' or
                                        'text' format that displays statistics
                                        for a particular SQL statement from a
                                        range of snapshot IDs in a 'specific'
                                        database instance. You will be prompted
                                        to specify the SQL ID for a specific SQL
                                        statement, allowing for targeted
                                        analysis and performance tuning.

+-------------------------+
| Compare Periods Reports |
+-------------------------+

$ORACLE_HOME/rdbms/admin/awrddrpt.sql   Generates an 'HTML' or 'text' report
                                        that compares detailed performance
                                        attributes and configuration settings
                                        between two selected time periods on the
                                        'local' database instance.

$ORACLE_HOME/rdbms/admin/awrddrpi.sql   Generates an 'HTML' or 'text' report
                                        that compares detailed performance
                                        attributes and configuration settings
                                        between two selected time periods on a
                                        'specific' database and instance. This
                                        script enables you to specify a database
                                        identifier and instance for which AWR
                                        Compare Periods report will be
                                        generated.

--------------------------------------------------------------------------------
SQL Developer and AWR Reports
--------------------------------------------------------------------------------

If you are using SQL Developer 4 onward, you can view AWR reports directly from
SQL Developer. If it is not already showing, open the DBA pane "View > DBA",
expand the connection of interest, then expand the "Performance" node.
The AWR reports are available from the "AWR" node.

-------------------------------------------------------------------------------
Purging Old Snapshots
--------------------------------------------------------------------------------

AWR snapshots can be purged which can reduce space taken up in the SYSAUX
tablespace.

For example, use the "DBMS_WORKLOAD_REPOSITORY.drop_snapshot_range" procedure to
delete snapshot- IDs 50 - 80:

    BEGIN
      DBMS_WORKLOAD_REPOSITORY.drop_snapshot_range(low_snap_id  => 50,
                                                   high_snap_id => 80);
    END;
    /
