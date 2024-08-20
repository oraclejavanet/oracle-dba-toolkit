================================================================================
                         Oracle Database Authentication
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Overview
    [*] Using an Oracle Auto Login (Local) Wallet
    [*] Using an Oracle Database Authentication Options File

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

The Oracle DBA Toolkit includes several maintenance scripts that require
authentication to a target Oracle database. To ensure security and proper
authentication, these scripts support the following methods:

    1.  Oracle Auto Login (Local) Wallet
        
        This method uses an auto login wallet to authenticate to the target
        database. The wallet must be configured on the local machine where the
        script is run. This is the preferred method as it eliminates the need to
        provide access credentials directly within the script or on the command
        line.

    2.  Oracle Database Authentication Options File
        
        This file contains the necessary authentication information and is
        securely stored. The script references this file to authenticate to the
        database. The options file must be properly secured to prevent
        unauthorized access.

Directly passing access credentials such as username and password on the command
line is not supported by the Oracle DBA Toolkit. This is to prevent potential
security risks associated with exposing credentials in command history or
process listings.

--------------------------------------------------------------------------------
Using an Oracle Auto Login (Local) Wallet
--------------------------------------------------------------------------------

Using an Oracle wallet is the preferred method for database authentication as it
eliminates the need to provide access credentials directly within the script or
on the command line, thus enhancing security.

To use an Oracle wallet for authentication, specify the
'--authenticationMethod=wallet' option when running the script. For example:

    bin/rman-backup.sh --db=cdb1 --sid=cdb1 --authenticationMethod=wallet

For instructions on creating a Secure External Password Store (SEPS) using an
Oracle Wallet and enabling the auto login feature, see:

    doc/README-create-seps-using-oracle-wallet.txt 

--------------------------------------------------------------------------------
Using an Oracle Database Authentication Options File
--------------------------------------------------------------------------------

To use an Oracle database authentication options file instead of an Oracle
wallet, create the options file ~/.oracle-auth.conf on the database server as
the OS user running the script using the format:

---------------------------------------------------------------
[<target-database-name>]
host=<oracle host to connect to>
port=<oracle Listener port>
service-name=<network service name for the database>
user=<username for authentication>
password=<password for authentication>

[<catalog-database-name>]
host=<oracle host to connect to>
port=<oracle Listener port>
service-name=<network service name for the database>
user=<username for authentication>
password=<password for authentication>
---------------------------------------------------------------

For example:

---------------------------------------------------------------
[cdb1]
host=datanode.acmeindustries.com
port=1521
service-name=cdb1.acmeindustries.com
user=c##dbadmin
password=DbAdminPasswd

[catdb]
host=packmule.acmeindustries.com
port=1521
service-name=catdb.acmeindustries.com
user=rman
password=RmanPasswd
---------------------------------------------------------------

Similar to an Oracle Wallet, utilize operating system privileges to control
access to the Oracle database authentication options file:

$ chmod 600 ~/.oracle-auth.conf
$ chown \$(id -u):\$(id -g) ~/.oracle-auth.conf

To use an Oracle database authentication options file for authentication,
specify the '--authenticationMethod=authfile' option when running the script.
For example:

    bin/rman-backup.sh --db=cdb1 --sid=cdb1 --authenticationMethod=authfile
