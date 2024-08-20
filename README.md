# Oracle DBA Toolkit

<p align="center">

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate/?hosted_button_id=W45Y5ENDC7M9C)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/oraclejavanet/oracle-dba-toolkit/blob/main/LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/oraclejavanet/oracle-dba-toolkit/activity)
[![Maintainer](https://img.shields.io/badge/maintainer-Jeffrey%20M.%20Hunter-blue)](https://github.com/oraclejavanet/)
[![stability-alpha](https://img.shields.io/badge/stability-alpha-f4d03f.svg)](https://github.com/oraclejavanet/oracle-dba-toolkit)
[![LinkedIn Profile](https://img.shields.io/badge/LinkedIn-oraclejavanet-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/oraclejavanet/)

</p>

## Overview

<p>
    <b>Coming in Fall 2024</b>
</p>

Written by [Jeffrey M. Hunter](https://github.com/oraclejavanet/), the Oracle DBA
Toolkit is a collection of Shell scripts, SQL scripts, PL/SQL code, C programs,
and other useful utilities designed to facilitate the management and
administration of Oracle databases. 

Used by database administrators, developers and other professionals working with
Oracle Database, this toolkit aims to streamline common tasks and provide useful
utilities to enhance your workflow.

## Table of Contents

[Compatibility](#compatibility)<br />
[Prerequisites](#prerequisites)<br />
[Oracle DBA Toolkit Installation User](#oracle-dba-toolkit-installation-user)<br />
[Installation](#installation)<br />
[Getting Started](#getting-started)<br />
[Custom Directory](#custom-directory)<br />
[Contributing](#contributing)<br />
[Upcoming Enhancements](#upcoming-enhancements)<br />
[License](#license)<br />
[Disclaimer](#disclaimer)

## Compatibility

### Supported Database Versions

* Oracle Database 23ai
* Oracle Database 21c
* Oracle Database 19c
* Oracle Database 18c
* Oracle Database 12c Release 2 (12.2)
* Oracle Database 12c Release 1 (12.1)

### Supported Operating Systems

* Linux
* Oracle Solaris
* Microsoft Windows - (minimal support only)

### Supported Database Features

* Oracle Multitenant
* Oracle Real Application Clusters (RAC)

## Prerequisites

Before you begin, ensure that you have the following:

* Git installed on your local machine or on the database server.
* Access to the database server where the Oracle DBA Toolkit will be installed.
* Sufficient permissions on the database server to set environment variables, create directories, and copy files to the install directory.
* DBA access to the target Oracle databases. 
* Installation on Unix/Linux requires Bash version 4 or later.
* Installation on Microsoft Windows requires PowerShell version 5.1 or later.

**Note:** The Oracle DBA Toolkit needs to be installed on each database server
          in your environment to ensure proper functionality.

## Oracle DBA Toolkit Installation User

Choose an operating system account on the database server to install the Oracle
DBA Toolkit.

While it is possible to install the Oracle DBA Toolkit as the Oracle
installation user (`oracle`) on the database server, it is recommended for
security reasons to use a dedicated user, such as `dbadmin`. In this case,
`dbadmin` would be the designated _Oracle DBA Toolkit Installation User_ for
installing and managing the toolkit on the database server.

## Installation

Installing the Oracle DBA Toolkit involves cloning its repository to a local
machine and copying it to a remote database server(s).

**Note:** If Git is installed on the database server, you can clone the
repository directly on the server, eliminating the need to use a local machine.

The Oracle DBA Toolkit can be installed to any directory on the database server.
The instructions below demonstrate how to install the Oracle DBA Toolkit as the
user `dbadmin` to `/opt/oracle-dba-toolkit` on Unix/Linux and
`C:\opt\oracle-dba-toolkit` on Microsoft Windows.

### For Unix/Linux

1. **Clone the Repository**

    Clone the repository to a file system on your local machine, or directly to
    the database server if Git is installed.

    For example:

    ```
    cd ~/repos
    git clone https://github.com/oraclejavanet/oracle-dba-toolkit.git
    ```

2. **Copy the Repository to the Database Server**

    If you cloned the repository on a machine other than the database server,
    copy it to the remote server(s).

    Use the `scp` command from your local machine to copy the repository to the
    remote database server.
    
    For example, to copy the repository from your local machine to the
    `repos` directory on a database server named `datanode` as the Oracle DBA
    Toolkit installation user `dbadmin`:

    ```
    scp -rp ~/repos/oracle-dba-toolkit dbadmin@datanode:repos/
    ```

3. **Copy the Repository to the Desired Directory**

    Log on to the database server as the Oracle DBA Toolkit installation user.

    As the installation user, navigate to the directory on the database server
    where you want to install the Oracle DBA Toolkit. For example, if you want
    to install it in `/opt/oracle-dba-toolkit`, create the directory (if it
    doesn’t already exist) and copy the repository contents.

    ```
    sudo mkdir -p /opt/oracle-dba-toolkit
    sudo chown dbadmin:dbadmin /opt/oracle-dba-toolkit
    cp -r ~/repos/oracle-dba-toolkit/* /opt/oracle-dba-toolkit/
    ```

4. **Set Permissions**

    Ensure that the necessary scripts have the correct permissions. You may need
    to make the shell scripts executable.

    ```
    find /opt/oracle-dba-toolkit -name "*.sh" -exec chmod +x {} \;
    ```

    **Note:** You may also need to adjust file/directory permissions as needed
    to ensure the toolkit operates correctly.
    
    For example:

    ```
    sudo chmod g+w /opt/oracle-dba-toolkit/log
    sudo chown dbadmin:dba /opt/oracle-dba-toolkit/log
    ```

5. **Update Environment Variables**

    Update your environment variables to include the Oracle DBA Toolkit
    directory in your `PATH` and `ORACLE_PATH`. Add the following lines to your
    shell configuration file (e.g., `.bashrc`, `.bash_profile`, `.zshrc`).

    ```
    # ---------------------------------------------------
    # Oracle DBA Toolkit
    # ---------------------------------------------------
    export ORACLE_DBA_TOOLKIT_HOME=/opt/oracle-dba-toolkit
    export ORACLE_PATH=$ORACLE_PATH:$ORACLE_DBA_TOOLKIT_HOME/sql
    export PATH=$PATH:$ORACLE_DBA_TOOLKIT_HOME/bin
    ```

    After adding the lines, reload your shell configuration.

    ```
    source ~/.bashrc  # or source ~/.zshrc, depending on your shell
    ```

### For Windows

You can use PowerShell to install the Oracle DBA Toolkit on Microsoft Windows.

1. **Clone the Repository**

    Clone the repository to a file system on your local machine, or directly to
    the database server if Git is installed.

    For example:

    ```
    cd "C:\Users\dbadmin\repos"
    git clone https://github.com/oraclejavanet/oracle-dba-toolkit.git
    ```

2. **Copy the Repository to the Database Server**

    If you cloned the repository on a machine other than the database server,
    copy it to the remote server(s).

    You can use tools like WinSCP or PSFTP for this purpose, or you can manually
    copy the repository using shared folders if the remote server is within your
    local network.

    To copy the repository to a remote Windows server using PowerShell, you can
    use the `Copy-Item` cmdlet in conjunction with the `-ToSession` parameter
    for remote sessions.
    
    For example, to copy the repository from your local machine to the `repos`
    directory on a database server named `datanode` as the Oracle DBA Toolkit
    installation user `dbadmin` using PowerShell:

    ```
    # Establish a remote session
    $remoteServer = 'datanode'
    $credential = Get-Credential -UserName 'dbadmin' -Message 'Enter the password for the remote server'
    $session = New-PSSession -ComputerName $remoteServer -Credential $credential

    # Copy the directory
    $sourceDirectory = 'C:\Users\dbadmin\repos\oracle-dba-toolkit'
    $destinationDirectory = 'C:\Users\dbadmin\repos\oracle-dba-toolkit'
    Copy-Item -Path $sourceDirectory -Destination $destinationDirectory -Recurse -ToSession $session
    ```

3. **Copy the Repository to the Desired Directory**

    Log on to the database server as the Oracle DBA Toolkit installation user
    and copy the repository where you want to install the Oracle DBA Toolkit. 
    
    For example, if you want to install it in `C:\opt\oracle-dba-toolkit`, copy
    the repository contents using PowerShell as follows:

    ```
    Copy-Item -Path "C:\Users\dbadmin\repos\oracle-dba-toolkit" -Destination "C:\opt\oracle-dba-toolkit" -Recurse
    ```

4. **Update Environment Variables**

    Update your environment variables to include the Oracle DBA Toolkit
    directory in your `ORACLE_DBA_TOOLKIT_HOME`, `PATH` and `SQLPATH` using the
    provided PowerShell script `ORACLE_DBA_TOOLKIT_HOME\bin\oracle-dba-toolkit.ps1`.

    ```
    cd C:\opt\oracle-dba-toolkit\bin
    ./oracle-dba-toolkit --add-paths
    ```

    **Note:** After adding the new paths, close and reopen PowerShell to ensure
    that the changes take effect.
    
## Getting Started

Welcome to the Oracle DBA Toolkit!

This section will guide you through the initial steps to get started after
installing the toolkit.

### Verify Installation

First, verify that the Oracle DBA Toolkit has been installed correctly.

**Unix/Linux:**

Open a terminal as the Oracle DBA Toolkit installation user and run the
following command:

```
oracle-dba-toolkit --check-config
```

If the installation was successful, this command will display the version of
the toolkit, the current configuration, and highlight any issues that need to
be addressed.

**Windows:**

Open a PowerShell window as the Oracle DBA Toolkit installation user and run
the following command:

```
oracle-dba-toolkit --check-config
```

If the installation was successful, this command will display the version of
the toolkit, the current configuration, and highlight any issues that need to
be addressed.

### Documentation

The Oracle DBA Toolkit includes documentation to help you make the best use of
its features. This includes:

* [Oracle DBA Toolkit Defaults Configuration File](doc/README-toolkit-defaults-config.txt)
* [Oracle Database Authentication](doc/README-oracle-database-authentication.txt)
* [Create Oracle Wallet for SEPS Database Connections](doc/README-create-seps-using-oracle-wallet.txt)
* [Setup Email Functionality on a Database Server for Script Notifications](doc/README-email.txt)
* [Oracle Recovery Manager (RMAN) Backup](doc/README-rman-backup.txt)
* [Oracle Data Pump (Logical) Backup](doc/README-dpump-backup.txt)
* [Oracle External Procedures](doc/README-external-procedures.txt)
* [Automatic Workload Repository (AWR)](doc/README-automatic-workload-repository.txt)

### Configuring Toolkit Defaults

The Unix/Linux scripts in the `bin` directory of the Oracle DBA Toolkit support
command line parameters for increased flexibility and customization.

In addition to command line parameters, users can provide default values for
some of the key parameters in the `conf/toolkit-defaults.conf` configuration
file, offering further flexibility and ease of use in the scripts.

**Note:** Options supplied on the command line take precedence over those
          specified in the configuration file.

See the following note on how to specify default options in the
`conf/toolkit-defaults.conf` configuration file:

* [Oracle DBA Toolkit Defaults Configuration File](doc/README-toolkit-defaults-config.txt)

### Running Oracle SQL Scripts

By adding the `sql` directory for the Oracle DBA Toolkit to the `ORACLE_PATH`
environment variable on Unix/Linux or `SQLPATH` on Windows, you can execute SQL
scripts from any directory in SQL*Plus. This simplifies the process, as you no
longer need to specify the full path to the `.sql` script to run it.

1. List SQL categories and available scripts.

    ```
    SQL> @help.sql
    ```

2. Running a SQL script.

    ```
    SQL> @sql-script.sql
    ```

3. Examples.

    **Connect to Target Database**

    ```
    SQL> connect /@soedb
    Connected.
    ```

    **Tablespace Usage**

    ```
    SQL> @dba-tablespaces

    +------------------------------------------------------------------------------+
    | Report  : Tablespace Usage                                                   |
    | Session : c##dbadmin@//datanode/soedb.acmeindustries.com                     |
    +------------------------------------------------------------------------------+

    Status    Tablespace Name                Type             Size (MB)    Free (MB)    Used (MB) % Used Max Size (MB) % Max Used
    --------- ------------------------------ ------------- ------------ ------------ ------------ ------ ------------- ----------
    ONLINE    POOKIE                         PERMANENT            1,712          174        1,538     90        33,280          5
    ONLINE    SOE                            PERMANENT           28,262        3,744       24,518     87    33,554,432          0
    ONLINE    SYSAUX                         PERMANENT            6,365          391        5,974     94        32,768         18
    ONLINE    SYSTEM                         PERMANENT            1,024          274          750     73        32,768          2
    ONLINE    TEMP                           TEMPORARY            8,892        8,892            0      0        32,768          0
    ONLINE    UNDOTBS1                       UNDO                   720          658           62      9        32,768          0
    ONLINE    USERS                          PERMANENT              500          499            1      0        32,768          0
                                                          ------------ ------------ ------------ ------ ------------- ----------
    avg                                                                                               50                        4
    sum                                                          47,475       14,632       32,843           33,751,552
    ```

    **Blocking Locks (Incidents)**

    ```
    SQL> @locks-blocking

    +------------------------------------------------------------------------------+
    | Report  : Blocking Locks - Incidents                                         |
    | Session : sys@//datanode/soedb.acmeindustries.com                            |
    +------------------------------------------------------------------------------+

    +------------------------------------------------------------------------------+
    | BLOCKING LOCKS (Summary)                                                     |
    +------------------------------------------------------------------------------+

    Number of blocking lock incidents: 2

    Incident 1
    ---------------------------------------------------------------------------------------------------------
                            WAITING                                  BLOCKING
                            ---------------------------------------- ----------------------------------------
    Instance Name         : cdb1                                     cdb1
    Oracle SID            : 70                                       323
    Serial#               : 64209                                    39019
    Oracle User           : JHUNTER                                  SOE
    O/S User              : dbadmin                                  dbadmin
    Logon Time            : 06/30/2024 06:14 PM                      06/30/2024 06:09 PM
    Client Machine        : datanode.acmeindustries.com              datanode.acmeindustries.com
    Database Machine      : datanode.acmeindustries.com              datanode.acmeindustries.com
    O/S PID               : 3880188                                  3878233
    Terminal              : pts/5                                    pts/3
    Lock Time             : 6 minutes                                11 minutes
    Status                : ACTIVE                                   INACTIVE
    Program               : sqlplus@datanode.acmeindustries.com (TN  sqlplus@datanode.acmeindustries.com (TN
    Waiter Lock Type      : Transaction
    Waiter Mode Request   : Exclusive
    Waiting SQL           : delete from soe.customers where cust_first_name = 'jack'

    Incident 2
    ---------------------------------------------------------------------------------------------------------
                            WAITING                                  BLOCKING
                            ---------------------------------------- ----------------------------------------
    Instance Name         : cdb1                                     cdb1
    Oracle SID            : 77                                       323
    Serial#               : 12663                                    39019
    Oracle User           : JHUNTER                                  SOE
    O/S User              : jhunter                                  dbadmin
    Logon Time            : 06/30/2024 06:18 PM                      06/30/2024 06:09 PM
    Client Machine        : racnode1.acmeindustries.com              datanode.acmeindustries.com
    Database Machine      : datanode.acmeindustries.com              datanode.acmeindustries.com
    O/S PID               : 3882502                                  3878233
    Terminal              : pts/1                                    pts/3
    Lock Time             : 3 minutes                                11 minutes
    Status                : ACTIVE                                   INACTIVE
    Program               : sqlplus@racnode1.acmeindustries.com (TN  sqlplus@datanode.acmeindustries.com (TN
    Waiter Lock Type      : Transaction
    Waiter Mode Request   : Exclusive
    Waiting SQL           : delete from soe.customers where cust_first_name = 'larry'

    +------------------------------------------------------------------------------+
    | LOCKED OBJECTS                                                               |
    +------------------------------------------------------------------------------+

    Instance  SID / Serial#   Status    Locking Oracle User  Object Owner    Object Name               Object Type     Locked Mode
    --------- --------------- --------- -------------------- --------------- ------------------------- --------------- -------------------------
    cdb1      70 / 64209      ACTIVE    JHUNTER              SOE             ORDERS                    TABLE           Row-Exclusive (SX)
    cdb1      70 / 64209      ACTIVE    JHUNTER              SOE             ORDER_ITEMS               TABLE           Row-Exclusive (SX)
    cdb1      70 / 64209      ACTIVE    JHUNTER              SOE             PRODUCT_INFORMATION       TABLE           Row-Exclusive (SX)
    cdb1      70 / 64209      ACTIVE    JHUNTER              SOE             CUSTOMERS                 TABLE           Row-Exclusive (SX)
    cdb1      70 / 64209      ACTIVE    JHUNTER              SOE             ADDRESSES                 TABLE           Row-Exclusive (SX)
    cdb1      77 / 12663      ACTIVE    JHUNTER              SOE             ORDERS                    TABLE           Row-Exclusive (SX)
    cdb1      77 / 12663      ACTIVE    JHUNTER              SOE             ADDRESSES                 TABLE           Row-Exclusive (SX)
    cdb1      77 / 12663      ACTIVE    JHUNTER              SOE             CUSTOMERS                 TABLE           Row-Exclusive (SX)
    cdb1      77 / 12663      ACTIVE    JHUNTER              SOE             ORDER_ITEMS               TABLE           Row-Exclusive (SX)
    cdb1      77 / 12663      ACTIVE    JHUNTER              SOE             PRODUCT_INFORMATION       TABLE           Row-Exclusive (SX)
    cdb1      323 / 39019     INACTIVE  SOE                  SOE             CUSTOMERS                 TABLE           Row-Exclusive (SX)

    11 rows selected.
    ```

    **Oracle Directories**

    ```
    SQL> @dba-directories

    +------------------------------------------------------------------------------+
    | Report  : Oracle Directories                                                 |
    | Session : c##dbadmin@//datanode/soedb.acmeindustries.com                     |
    +------------------------------------------------------------------------------+

    Owner      Directory Name                 Directory Path
    ---------- ------------------------------ -------------------------------------------------------------------------------------
    SYS        DATA_PUMP_DIR                  /u01/app/oracle/admin/cdb1/dpdump/F89EBDD05D4DE229E053AE01A8C062EC
    SYS        DBMS_OPTIM_ADMINDIR            /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/admin
    SYS        DBMS_OPTIM_LOGDIR              /u01/app/oracle/product/19.0.0/dbhome_1/cfgtoollogs
    SYS        DPUMP_DUMP_DIR                 /u04/app/oracle/oradpump/SOEDB
    SYS        DPUMP_LOG_DIR                  /opt/oracle-dba-toolkit/log
    SYS        JAVA$JOX$CUJS$DIRECTORY$       /u01/app/oracle/product/19.0.0/dbhome_1/javavm/admin/
    SYS        OPATCH_INST_DIR                /u01/app/oracle/product/19.0.0/dbhome_1/OPatch
    SYS        OPATCH_LOG_DIR                 /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/log
    SYS        OPATCH_SCRIPT_DIR              /u01/app/oracle/product/19.0.0/dbhome_1/QOpatch
    SYS        ORACLE_BASE                    /u01/app/oracle
    SYS        ORACLE_HOME                    /u01/app/oracle/product/19.0.0/dbhome_1
    SYS        ORACLE_OCM_CONFIG_DIR          /u01/app/oracle/product/19.0.0/dbhome_1/ccr/state
    SYS        ORACLE_OCM_CONFIG_DIR2         /u01/app/oracle/product/19.0.0/dbhome_1/ccr/state
    SYS        SDO_DIR_ADMIN                  /u01/app/oracle/product/19.0.0/dbhome_1/md/admin
    SYS        SDO_DIR_WORK
    SYS        XMLDIR                         /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/xml
    SYS        XSDDIR                         /u01/app/oracle/product/19.0.0/dbhome_1/rdbms/xml/schema

    17 rows selected.
    ```

    **Fast Recovery Area (Overview)**

    ```
    SQL> @fra-status

    +------------------------------------------------------------------------------+
    | Report  : Fast Recovery Area - Overview                                      |
    | Session : c##dbadmin@//datanode/soedb.acmeindustries.com                     |
    +------------------------------------------------------------------------------+

    Recovery File Dest                       Space Limit (MB) Space Used (MB)  % Used Space Reclaimable (MB) % Reclaimable Number of Files
    ---------------------------------------- ---------------- --------------- ------- ---------------------- ------------- ---------------
    /u03/app/oracle/fast_recovery_area                256,000          75,665   29.56                      0           .00             367

    File Type                                Percent Space Used Percent Space Reclaimable Number of Files
    ---------------------------------------- ------------------ ------------------------- ---------------
    ARCHIVED LOG                                            .01                         0               3
    AUXILIARY DATAFILE COPY                                   0                         0               0
    BACKUP PIECE                                          21.36                         0             344
    CONTROL FILE                                            .01                         0               1
    FLASHBACK LOG                                             0                         0               0
    FOREIGN ARCHIVED LOG                                      0                         0               0
    IMAGE COPY                                                0                         0               0
    REDO LOG                                                .23                         0               3
    ```

    **Automatic Workload Repository (Snapshot Configuration)**

    ```
    SQL> @awr-config

    +------------------------------------------------------------------------------+
    | Report  : AWR - Snapshot Configuration Information                           |
    | Session : c##dbadmin@//datanode/soedb.acmeindustries.com                     |
    +------------------------------------------------------------------------------+

    DB Name    Container Name  Snapshot Interval (min) Retention Interval (min) Retention Interval (day)
    ---------- --------------- ----------------------- ------------------------ ------------------------
    CDB1       SOEDB                                15                   43,200                       30
    ```

    **Automatic Workload Repository (Snapshot Summary)**

    ```
    SQL> @awr-summary

    +------------------------------------------------------------------------------+
    | Report  : AWR - Snapshot Summary                                             |
    | Session : c##dbadmin@//datanode/soedb.acmeindustries.com                     |
    +------------------------------------------------------------------------------+

    Instance Name Container Name  SYSAUX Occupant  Schema       Space Used (MB) Snapshot Count Snapshot ID (Min) Snapshot ID (Max)
    ------------- --------------- ---------------- ------------ --------------- -------------- ----------------- -----------------
    cdb1          SOEDB           SM/AWR           SYS                    2,466          2,960              1249              4258
    ```

### Database Backups

The Oracle DBA Toolkit provides a set of scripts to help you perform and manage
database backups. These scripts support both physical and logical backups.

##### Physical Backups

Oracle Recovery Manager (RMAN) is a tool included with the Oracle database that
performs backup and recovery operations for Oracle databases. The toolkit
includes scripts that leverage RMAN to perform physical backups.

The following scripts can be used to perform regular physical backups of an
Oracle database using Oracle RMAN. The Unix/Linux scripts support full,
incremental, differential, and archived redo log only backups. You can also
configure backups to be written to an alternate location instead of the Fast
Recovery Area (FRA).

| Operating System   | Script Name                             | Documentation                                                       |
|--------------------|-----------------------------------------|---------------------------------------------------------------------|
| Unix/Linux         | [rman-backup.sh](bin/rman-backup.sh)    | [Oracle Recovery Manager (RMAN) Backup](doc/README-rman-backup.txt) |
| Microsoft Windows  | [rman-backup.ps1](bin/rman-backup.ps1)  | [Oracle Recovery Manager (RMAN) Backup](doc/README-rman-backup.txt) |

##### Logical Backups

Oracle Data Pump is a high-performance data movement tool included with the
Oracle database that enables you to move data and metadata between Oracle
databases and to perform logical backups that can be used for recovery
operations under certain user cases.

Logical backups contain logical data such as tables and stored procedures. You
can use Oracle Data Pump to export logical data to binary files, which you can
later import into the database. The toolkit includes scripts that leverage
Oracle Data Pump to perform logical backups.

The following scripts can be used to perform regular logical backups of an
Oracle database using Oracle Data Pump. The scripts allow you to specify
parameters such as the directory to store the backup files, the log file
location, and the retention period for backup files.

| Operating System   | Script Name                              | Documentation                                                    |
|--------------------|------------------------------------------|------------------------------------------------------------------|
| Unix/Linux         | [dpump-backup.sh](bin/dpump-backup.sh)   | [Oracle Data Pump (Logical) Backup](doc/README-dpump-backup.txt) |
| Microsoft Windows  | [dpump-backup.ps1](bin/dpump-backup.ps1) | [Oracle Data Pump (Logical) Backup](doc/README-dpump-backup.txt) |

## Custom Directory

The [`ORACLE_DBA_TOOLKIT_HOME/custom`](./custom/README.md) directory is designed
to be a persistent location for custom files and configurations that you want to
keep separate from the version-controlled files of the Oracle DBA Toolkit. Files
and directories here will not be affected by Git operations, making it an ideal
location for storing user-specific or customer-specific data.

## Contributing

My goal is to continually enhance the Oracle DBA Toolkit based on user feedback,
technological advancements, and evolving best practices. I welcome contributions
to the toolkit. If you would like to contribute, please follow these guidelines:

1. Fork the repository and create a new branch for your feature or bug fix.
2. Make your changes and ensure that they adhere to the coding standards.
3. Test your changes thoroughly.
4. Submit a pull request with a clear description of your changes.

## Upcoming Enhancements

### Overview

This section outlines the planned upcoming enhancements and improvements for the
Oracle DBA Toolkit.

### Planned Features

1. Enhanced Security Features

    * Implement an encryption method to secure clear-text passwords stored in
      the Oracle database authentication options file.

2. Performance

    * Add advanced performance monitoring tools to more effectively identify and
      resolve database bottlenecks.

3. Improved User Interface

    * Introduction of a web-based interface for easier management of database
      operations.

4. New Functionalities

    * Introduce new functionality to support advanced data analytics using
      Oracle AI Vector Search and retrieval-augmented generation (RAG).
    * Addition of a patch management tool to help keep Oracle databases up-to-date.

5. Expanded Compatibility

    * Expand compatibility to include additional Linux distributions, such as
      Ubuntu Server, and Unix operating systems, such as HP-UX and AIX.

## License

Copyright (c) 2024 Jeffrey M. Hunter.

GitHub: [@oraclejavanet](https://github.com/oraclejavanet)

This project is licensed under the
[MIT License](https://github.com/oraclejavanet/oracle-dba-toolkit/blob/main/LICENSE).
Feel free to use, modify, and distribute the code in accordance with the terms
of the license.

## Disclaimer

The Oracle DBA Toolkit (the "Toolkit") is provided "as is" without any express
or implied warranties, including, but not limited to, the implied warranties of
merchantability, fitness for a particular purpose, and non-infringement. In no
event shall the author or copyright holder be liable for any claim, damages, or
other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the Toolkit or the use or other dealings in
the Toolkit.

The user assumes full responsibility for any actions performed with the Toolkit
and acknowledges that using the Toolkit is at their own risk. The Toolkit may
cause data loss, data corruption, or other damages, and it is the user's
responsibility to ensure they have adequate backups and recovery procedures in
place.

Furthermore, the author of the Toolkit does not guarantee that it will meet your
requirements, that its operation will be uninterrupted or error-free, or that
defects in the Toolkit will be corrected. Users are encouraged to thoroughly
test the Toolkit in a non-production environment before deploying it in a live
setting.

By using the Oracle DBA Toolkit, you agree to these terms and conditions. If you
do not agree to these terms, do not use the Toolkit.
