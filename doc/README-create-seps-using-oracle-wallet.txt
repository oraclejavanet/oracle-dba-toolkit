================================================================================
               Create Oracle Wallet for SEPS Database Connections
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Synopsis
    [*] Overview
    [*] Quick Start
    [*] About Secure External Password Store
    [*] About Oracle Wallet
    [*] orapki versus mkstore
    [*] Create Oracle Wallet for SEPS Database Connections
    [*] Securing Access to Oracle Wallet
    [*] Managing Secure External Password Store Credentials
    [*] Best Practices

--------------------------------------------------------------------------------
Synopsis
--------------------------------------------------------------------------------

Create a Secure External Password Store (SEPS) using an Oracle Wallet and enable
the auto login feature that will allow database maintenance scripts to securely
log in to an Oracle database without the need to supply a clear-text password.

If you are only seeking a practical example on how to create an Oracle Wallet
for SEPS database connections, feel free to skip to the section:

    [*] Quick Start

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

The "Oracle DBA Toolkit" is a comprehensive set of shell scripts and utilities
designed to streamline and enhance the tasks performed by Oracle Database
Administrators. Many of the tools available in the toolkit require
authentication to an Oracle database using a specified username and password.

All too frequently, user credentials get stored in cleartext within shell
scripts, residing openly on the filesystem, presenting a potential security risk
and vulnerability to unauthorized access or data breaches.

An alternative approach, introduced with Oracle Database 10g Release 2, is to
utilize a Secure External Password Store (SEPS). Using this method, Oracle login
credentials are securely stored in a client-side Oracle Wallet. After fulfilling
the requirements of SEPS (explained in section "Create Oracle Wallet for SEPS
Database Connections"), users and applications will be able to read database
credentials from an auto login wallet (also called an SSO wallet) to establish
connections securely to an Oracle database using the '/@db_alias' syntax without
the need to specify a password.

This note explains how to create a Secure External Password Store using an
Oracle Wallet to securely store database credentials for use in shell scripts,
configurations, and other utilities.

--------------------------------------------------------------------------------
Quick Start
--------------------------------------------------------------------------------

1.  Create Oracle wallet directory.

    Unix/Linux

        ------------------------------------------------------------------------
        mkdir ~/.private
        mkdir ~/.private/wallet
        mkdir ~/.private/network
        mkdir ~/.private/certs
        chmod -R 700 ~/.private
        ------------------------------------------------------------------------

    Windows

        ------------------------------------------------------------------------
        set JAVA_HOME="C:\Program Files\Java\jdk1.8.0_181\"
        echo %ORACLE_HOME%
        mkdir C:\Users\dbadmin\private\wallet
        mkdir C:\Users\dbadmin\private\network
        mkdir C:\Users\dbadmin\private\certs
        ------------------------------------------------------------------------

2.  Specify the wallet path in the client's sqlnet.ora file using the directive
    WALLET_LOCATION.

    # +------------------------------------------------------------------------+
    # | /home/dbadmin/.private/network/sqlnet.ora                              |
    # +------------------------------------------------------------------------+
    NAMES.DIRECTORY_PATH = (TNSNAMES, LDAP, EZCONNECT)
    NAMES.DEFAULT_DOMAIN = <default domain>
    WALLET_LOCATION =
      (SOURCE =
        (METHOD = FILE)
        (METHOD_DATA =
          (DIRECTORY = /home/dbadmin/.private/wallet)
        )
      )
    SQLNET.WALLET_OVERRIDE = TRUE
    SSL_CLIENT_AUTHENTICATION = FALSE

3.  You retrieve/use a stored password by referencing a TNSALIAS configured in
    the client's tnsnames.ora file. For example:

    # +------------------------------------------------------------------------+
    # | /home/dbadmin/.private/network/tnsnames.ora                            |
    # +------------------------------------------------------------------------+
    DATADB_DBADMIN =
      (DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = datanode)(PORT = 1521))
        (CONNECT_DATA =
          (SERVER = DEDICATED)
          (SERVICE_NAME = datadb)
        )
      )

4.  Set the environment variable TNS_ADMIN to point to the OS user's dedicated
    destination for the sqlnet.ora and tnsnames.ora files. Persist the TNS_ADMIN
    environment variable in the startup script for the user
    (i.e., ~/.bash_profile).

    ----------------------------------------------------------------------------
    export TNS_ADMIN=/home/dbadmin/.private/network
    ----------------------------------------------------------------------------

5.  Create an auto login (local) Oracle wallet for the 'dbadmin' OS user
    account.

    Unix/Linux

        ------------------------------------------------------------------------
        orapki wallet create -wallet /home/dbadmin/.private/wallet -auto_login_local
        ------------------------------------------------------------------------

    Windows

        ------------------------------------------------------------------------
        mkstore -wrl C:\Users\dbadmin\private\wallet -create
        mkstore -wrl C:\Users\dbadmin\private\wallet -createLSSO
        ------------------------------------------------------------------------

6.  Add database credentials to the wallet.

    ----------------------------------------------------------------------------
    mkstore -wrl /home/dbadmin/.private/wallet -createCredential <db_alias> <db_user> <db_pwd>
    ----------------------------------------------------------------------------

    For example:

    ----------------------------------------------------------------------------
    mkstore -wrl /home/dbadmin/.private/wallet -createCredential datadb_dbadmin dbadmin dbadmin_pwd
    ----------------------------------------------------------------------------

7.  How to make a SEPS database connection using the TNSALIAS
    (a.k.a., db_alias).

    ----------------------------------------------------------------------------
    SQL> CONNECT /@datadb_dbadmin
    ----------------------------------------------------------------------------

8.  View the credentials in the wallet.

    ----------------------------------------------------------------------------
    mkstore -wrl /home/dbadmin/.private/wallet -listCredential
    ----------------------------------------------------------------------------

9.  Delete database credentials

    ----------------------------------------------------------------------------
    mkstore -wrl /home/dbadmin/.private/wallet -deleteCredential <db_alias>
    ----------------------------------------------------------------------------

--------------------------------------------------------------------------------
About Secure External Password Store
--------------------------------------------------------------------------------

Introduced in Oracle Database 10g Release 2, the Secure External Password Store
feature enhances security by eliminating the need to store clear-text database
account passwords in scripts or other tools that access the database without
user interaction. SEPS is an extension of the Oracle Wallet functionality
(see "About Oracle Wallet" in the next section).

The Secure External Password Store uses an Oracle Wallet to hold one or more
user name/password combinations to run batch processes and other tasks that
need to run without user interaction. The best way to envision the password
store is as a table with three columns: TNSALIAS (also known as 'db_alias'),
USERNAME, and PASSWORD. Multiple credentials for multiple database can be stored
in a single wallet file:

    | TNSALIAS (db_alias) | USERNAME | PASSWORD    |       SQL*Plus Connect Syntax
    | ------------------- | -------- | ----------- |       -----------------------------
    | erpdb               | jhunter  | jhunter-pwd |       SQL> CONNECT /@erpdb
    | datadb_dbadmin      | dbadmin  | dbadmin-pwd |       SQL> CONNECT /@datadb_dbadmin
    | datadb_jhunter      | jhunter  | jhunter-pwd |       SQL> CONNECT /@datadb_jhunter
    
TNSALIAS is basically the primary key that maps to a single user name/password
combination. In most deployment scenarios, this means creating a new "net
service name" or "connect identifier" entry in the tnsnames.ora file that
matches the TNSALIAS for each stored credential.

--------------------------------------------------------------------------------
About Oracle Wallet
--------------------------------------------------------------------------------

An Oracle Wallet is essentially a directory on a server that acts as a secure
repository for managing cryptographic assets such as private keys, digital
certificates, database credentials (SEPS), and other sensitive information used
for securing connections within an Oracle Database environment.

-------------------
Oracle Wallet Files
-------------------

Oracle Wallet files are a collection of files that comprise the Oracle Wallet
and store sensitive information and cryptographic assets used for secure
communication and authentication within Oracle products.

A configured auto login wallet for SEPS will consist of two files -
'ewallet.p12' and 'cwallet.sso' stored in a secure wallet directory. These two
wallet files are created using the command-line utility orapki (Oracle PKI
Tool).

    1.  ewallet.p12 - (Encryption Wallet File)

        This is the main wallet file which acts as a secure password-protected
        software container conforming to the PKCS #12 standard. This file
        (known as an Encryption wallet file) encapsulates critical cryptographic
        assets such as private keys, digital certificates, database credentials
        (SEPS), and other sensitive information essential for securing
        connections within Oracle Database.

        The encryption wallet file is protected with a wallet password. The
        wallet password is a passphrase that is used to encrypt and secure the
        contents of the wallet. When you create or open a wallet, you must
        provide the wallet password to access the sensitive information stored
        within it. The encryption wallet file is encrypted using the Triple Data
        Encryption Standard (3DES) algorithm.

        The encryption wallet file is created using the orapki command-line
        utility. For example:

        $ orapki wallet create -wallet $WALLET_DIR

    2.  cwallet.sso - (Auto Login Wallet File)

        To support SEPS, the Oracle Wallet directory will also contain a file
        named 'cwallet.sso', which is a Single Sign-On (SSO) wallet file used
        for securing sensitive information such as database credentials.
        
        Unlike the 'ewallet.p12' wallet file, 'cwallet.sso' does not rely on
        password protection but rather leverages operating system privileges for
        access (see section "Securing Access to Oracle Wallet"). The
        'cwallet.sso' file is also known as an Auto Login wallet, referred to as
        such because it enables authentication to an Oracle Database without
        manually specifying a password. This Auto Login capability is
        particularly valuable in scenarios such as automated scripts or
        scheduled tasks, where the '/@db_alias' syntax allows users to log in to
        an Oracle database without the need for explicitly specifying a
        password.

        When creating the Oracle wallet, use the -auto_login or
        -auto_login_local option of the orapki command-line utility to create
        the auto login wallet file. It should be noted that the auto login
        wallet is not encrypted. Otherwise it would not be possible to read
        passwords from it without authentication. The auto login option creates
        a decrypted and obfuscated copy (cwallet.sso) from the original
        encrypted wallet (ewallet.p12).

        An auto login (local) wallet is created using the orapki command-line
        utility with the -auto_login_local option. For example:

        $ orapki wallet create -wallet $WALLET_DIR -auto_login_local

    3.  sqlnet.ora / tnsnames.ora
    
        While not strictly part of the wallet, these files are used to
        configure and manage the Oracle Net Services, which is Oracle's network
        layer that facilitates communication between clients and servers.

        The WALLET_LOCATION directive in 'sqlnet.ora' is used to specify the
        location of the Oracle Wallet. The 'tnsnames.ora' file is a
        configuration file that maps Oracle Net Services service names
        (TNSALIAS) to connect descriptors. The connection descriptor defines the
        connection details for an Oracle instance, such as the Oracle database's
        hostname, port, and service name. The TNSALIAS, often referred to as
        db_alias, is a short and easy-to-remember name associated with a
        specific database instance. In the context of Oracle Wallet, when adding
        credentials to the wallet, the db_alias is the TNSNAMES entry that you
        use in your connection strings to refer to a specific database.

------------------------
Advanced Security Option
------------------------

It is not necessary to purchase an Advanced Security Option (ASO) license to
use Oracle Wallet. This feature can be used with both Standard Edition and
Enterprise Edition.

----------------------
Oracle Wallet Location
----------------------

The Oracle Wallet is typically stored in a directory on the server file system. 

The wallet path must be specified in the client's sqlnet.ora file using the
directive WALLET_LOCATION. For example, if the Oracle Wallet is located at
'/home/dbadmin/.private/wallet':

    +-------------------------------------------+
    | /home/dbadmin/.private/network/sqlnet.ora |
    |--------------------------------------------------------------------------+
    | WALLET_LOCATION =                                                        |
    |   (SOURCE =                                                              |
    |     (METHOD = FILE)                                                      |
    |     (METHOD_DATA =                                                       |
    |       (DIRECTORY = /home/dbadmin/.private/wallet)                        |
    |     )                                                                    |
    |   )                                                                      |
    |                                                                          |
    | SQLNET.WALLET_OVERRIDE = TRUE                                            |
    | SSL_CLIENT_AUTHENTICATION = FALSE                                        |
    +--------------------------------------------------------------------------+

    Note: Set the SQLNET.WALLET_OVERRIDE parameter to TRUE to enable the Secure
          External Password Store.

You retrieve/use a stored password by referencing a TNSALIAS configured in the
client's tnsnames.ora file.

    +---------------------------------------------+
    | /home/dbadmin/.private/network/tnsnames.ora |
    |--------------------------------------------------------------------------+
    | DATADB_DBADMIN =                                                         |
    |   (DESCRIPTION =                                                         |
    |     (ADDRESS = (PROTOCOL = TCP)(HOST = datanode)(PORT = 1521))           |
    |     (CONNECT_DATA =                                                      |
    |       (SERVER = DEDICATED)                                               |
    |       (SERVICE_NAME = datadb)                                            |
    |     )                                                                    |
    |   )                                                                      |
    +--------------------------------------------------------------------------+

How to make a SEPS database connection using the TNSALIAS (a.k.a., db_alias).

    ----------------------------------------------------------------------------
    SQL> CONNECT /@datadb_dbadmin
    ----------------------------------------------------------------------------

----------------------
Oracle Client Software
----------------------

If the target machine is a client computer and not a database server running
the Oracle Database software, make certain to install the Oracle Database Client
software (based in an Oracle home). Oracle Wallet manager is not included with
an Oracle Instant Client install.
	
See Doc ID 340559.1 for further information.

--------------------------------------------------------------------------------
orapki versus mkstore
--------------------------------------------------------------------------------

orapki and mkstore are command-line utilities provided by Oracle for managing
and manipulating an Oracle Wallet. Both utilities can be used to create the
wallet files 'ewallet.p12' and 'cwallet.sso'. This section provides a brief
overview of each utility.

    * orapki (Oracle PKI Tool)
	
      orapki is a command-line Oracle utility that you can use to create
      wallets, and then add and manage certificates in the wallet. orapki
      provides a wider range of functionality than mkstore for managing
      Public Key Infrastructure (PKI) components within an Oracle Wallet. It
      allows you to perform operations such as creating and managing certificate
      requests (CSRs), generating and managing digital certificates, handling
      Certificate Revocation Lists (CRLs), and exporting and importing PKI
      components. orapki provides more advanced features for working with
      certificates and keys, making it suitable for more complex PKI-related
      tasks.

      Starting in Oracle Database release 23ai, the command-line utility mkstore
      is deprecated. While Oracle recommends to use the orapki utility instead
      of mkstore, not all of the functionality needed to manage database
      credentials in an Oracle wallet are available in orapki. After 23ai,
      Oracle has committed to enhancing the orapki command-line utility to
      include all of the missing functionality for managing database credentials
      for SEPS that is currently only available in mkstore.  

    * mkstore (Oracle Secret Store Tool)
       
      mkstore is a command-line utility used to create an Oracle Wallet and
      add/manage secrets (i.e., credentials) in the wallet. Like orapki, mkstore
      is available in the the Oracle Database client software.

      +------------------------------------------------------------------------+
      | mkstore Deprecated in Oracle Database release 23ai                     |
      +------------------------------------------------------------------------+

      Starting in Oracle Database release 23ai, mkstore is deprecated. Oracle
      recommends that you use the orapki instead of mkstore. While Oracle
      recommends to use the orapki utility instead of mkstore, not all of the
      functionality needed to manage database credentials in an Oracle wallet
      are available in orapki. After 23ai, Oracle has committed to enhancing the
      orapki command-line utility to include all of the missing functionality
      for managing database credentials for SEPS that is currently only
      available in mkstore. 

      See the Oracle Security Guide for 23ai, section:

          B.1.4 Tools Used to Manage Oracle Database Wallets and Certificates

      The following post was submitted by Rlowenth-Oracle on May 1 2023:

          We (Oracle) will be enhancing orapki AFTER 23ai to include the missing
          functionality that is currently in mkstore. Essentially (right now)
          we find ourselves maintaining two different command line utilities -
          and forcing YOU to learn syntax for two different utilities - where
          we can easily shrink things down to a single utility. We want to fix
          that in an upcoming version of the database utilities.

          Notice that for 23ai, we are only deprecating the utility - no changes
          at this time. We just want to make sure the community is aware that
          we are planning to fix this in an upcoming release.

           https://forums.oracle.com/ords/apexds/post/mkstore-deprecated-1919

    * Oracle Wallet Manager (OWM)
	
      Oracle Wallet Manager is deprecated with Oracle Database 21c. Starting
      with Oracle Database 23ai, the Oracle Wallet Manager is officially
      desupported. Oracle recommends using the orapki command line tool to
      replace OWM (and mkstore).

--------------------------------------------------------------------------------
Create Oracle Wallet for SEPS Database Connections
--------------------------------------------------------------------------------

For an application to be able to read database credentials from an Oracle wallet
without manually entering the wallet password, the wallet needs to be created
with the auto login option (also called an SSO wallet).

This section contains detailed instructions on how to create an Oracle Wallet
for SEPS database connections for the Unix/Linux OS user 'dbadmin'. This is a
dedicated privileged user account I use for running database maintenance
scripts and to perform routine database administration tasks.

In this section, the 'dbadmin' OS account will be configured to securely connect
to an Oracle database named 'datadb' as the 'DBADMIN' database user using the
'/@datadb' syntax.

The examples in this section were conducted on a database server running Oracle
Database 19c (19.21) on the Unix/Linux operation system.

    1.  Create a directory named '.private' in the home directory of the user
        and then create the subdirectories 'wallet' and 'network' to maintain a
        clean and organized structure for the Oracle wallet and a dedicated
        destination for the tnsnames.ora and sqlnet.ora files. Optionally,
        create a subdirectory named 'certs' to store any cryptographic elements
        such as SSL/TLS certificates.

            /home/dbadmin/.private
            |
            +-- wallet
            │   +-- <wallet files and configurations>
            |
            +-- network
            |   |-- sqlnet.ora
            |   +-- tnsnames.ora
            |
            +-- certs (optional)
                |-- <SSL/TLS certificates>
                +-- <root or intermediate certificates from CA>

        Unix/Linux

            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ mkdir ~/.private
            [dbadmin@datanode ~]$ mkdir ~/.private/wallet
            [dbadmin@datanode ~]$ mkdir ~/.private/network
            [dbadmin@datanode ~]$ mkdir ~/.private/certs
            [dbadmin@datanode ~]$ chmod -R 700 ~/.private
            --------------------------------------------------------------------

        Windows

            When creating an Oracle wallet on Microsoft Windows, make certain to
            add a trailing '\' to the JAVA_HOME location. Also, verify that
            ORACLE_HOME is set to the Oracle Database Client software directory.
            Not setting ORACLE_HOME will result in errors when attempting to add
            credentials later in this section.

            --------------------------------------------------------------------
            C:\Users\dbadmin>set JAVA_HOME="C:\Program Files\Java\jdk1.8.0_181\"
            C:\Users\dbadmin>echo %ORACLE_HOME%
            C:\Users\dbadmin>mkdir C:\Users\dbadmin\private\wallet
            C:\Users\dbadmin>mkdir C:\Users\dbadmin\private\network
            C:\Users\dbadmin>mkdir C:\Users\dbadmin\private\certs
            --------------------------------------------------------------------

    2.  Create an auto login (local) Oracle wallet for the 'dbadmin' OS user
        account.

        Use the orapki command-line utility on an empty directory with the
        -auto_login_local option to create an auto login (local) wallet. The
        auto login option first creates the Encryption Wallet File (ewallet.p12)
        and then creates the Auto Login Wallet File (cwallet.sso) which is a
        decrypted and obfuscated wallet file from the encrypted wallet file
        (ewallet.p12).

            Note: The mkstore utility can also be used to create the Oracle
                  Wallet; however, it is deprecated in Oracle Database 23ai. It
                  is provided in this note for completeness only.

        Unix/Linux

            # using orapki
            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ orapki wallet create -wallet /home/dbadmin/.private/wallet -auto_login_local
            Oracle PKI Tool Release 19.0.0.0.0 - Production
            Version 19.4.0.0.0
            Copyright (c) 2004, 2023, Oracle and/or its affiliates. All rights reserved.

            Enter password: ************
            Enter password again: ************
            Operation is successfully completed.

            [dbadmin@datanode ~]$ ls -l ~/.private/wallet
            total 8
            -rw------- 1 dbadmin dbadmin 194 Dec 12 12:51 cwallet.sso
            -rw------- 1 dbadmin dbadmin   0 Dec 12 12:51 cwallet.sso.lck
            -rw------- 1 dbadmin dbadmin 149 Dec 12 12:51 ewallet.p12
            -rw------- 1 dbadmin dbadmin   0 Dec 12 12:51 ewallet.p12.lck
            --------------------------------------------------------------------

            or 

            # using mkstore (deprecated)
            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ mkstore -wrl /home/dbadmin/.private/wallet -create -createLSSO
            --------------------------------------------------------------------

        Windows

            --------------------------------------------------------------------
            C:\Users\dbadmin>mkstore -wrl C:\Users\dbadmin\private\wallet -create
            C:\Users\dbadmin>mkstore -wrl C:\Users\dbadmin\private\wallet -createLSSO
            --------------------------------------------------------------------

    3.  Configure the location of the Oracle Wallet in the user's dedicated
        sqlnet.ora file. Also, set the SQLNET.WALLET_OVERRIDE parameter to TRUE
        to enable the Secure External Password Store.

            # +----------------------------------------------------------------+
            # | /home/dbadmin/.private/network/sqlnet.ora                      |
            # +----------------------------------------------------------------+

            NAMES.DIRECTORY_PATH = (TNSNAMES, LDAP, EZCONNECT)
            NAMES.DEFAULT_DOMAIN = ACMEINDUSTRIES.COM

            WALLET_LOCATION =
              (SOURCE =
                (METHOD = FILE)
                (METHOD_DATA =
                  (DIRECTORY = /home/dbadmin/.private/wallet)
                )
              )

            SQLNET.WALLET_OVERRIDE = TRUE
            SSL_CLIENT_AUTHENTICATION = FALSE

    4.  Configure the connection string for the 'datadb' database in the
        user's dedicated tnsnames.ora file.

            # +----------------------------------------------------------------+
            # | /home/dbadmin/.private/network/tnsnames.ora                    |
            # +----------------------------------------------------------------+

            DATADB.ACMEINDUSTRIES.COM =
              (DESCRIPTION =
                (ADDRESS = (PROTOCOL = TCP)(HOST = datanode.acmeindustries.com)(PORT = 1521))
                (CONNECT_DATA =
                  (SERVER = DEDICATED)
                  (SERVICE_NAME = datadb.acmeindustries.com)
                )
              )

    5.  Set the environment variable TNS_ADMIN to point to the OS user's
        dedicated destination for the sqlnet.ora and tnsnames.ora files. Persist
        the TNS_ADMIN environment variable in the startup script for the user
        (i.e., ~/.bash_profile).

            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ export TNS_ADMIN=/home/dbadmin/.private/network
            --------------------------------------------------------------------

    6.  Add database credentials to the wallet. Supply the database connect
        string (i.e., DATADB) along with a database username and password.

            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ mkstore -wrl /home/dbadmin/.private/wallet -createCredential datadb dbadmin <dbadmin-pwd>
            Oracle Secret Store Tool Release 19.0.0.0.0 - Production
            Version 19.4.0.0.0
            Copyright (c) 2004, 2023, Oracle and/or its affiliates. All rights reserved..

            Enter wallet password: ************
            --------------------------------------------------------------------

    7.  View the credentials in the wallet.

            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ mkstore -wrl /home/dbadmin/.private/wallet -listCredential
            Oracle Secret Store Tool Release 19.0.0.0.0 - Production
            Version 19.4.0.0.0
            Copyright (c) 2004, 2023, Oracle and/or its affiliates. All rights reserved.

            Enter wallet password: ************
            List credential (index: connect_string username)
            1: datadb dbadmin
            --------------------------------------------------------------------

    8.  Test database credentials in the wallet.

            --------------------------------------------------------------------
            [dbadmin@datanode ~]$ sqlplus /nolog

            SQL*Plus: Release 19.0.0.0.0 - Production on Tue Dec 12 16:47:52 2023
            Version 19.21.0.0.0

            Copyright (c) 1982, 2022, Oracle.  All rights reserved.

            SQL> CONNECT /@datadb
            Connected.

            SQL> SHOW USER
            USER is "DBADMIN"
            --------------------------------------------------------------------

--------------------------------------------------------------------------------
Securing Access to Oracle Wallet
--------------------------------------------------------------------------------

Using a wallet doesn't prevent users from accessing the database credentials
contained in the wallet. Anyone having access to the wallet can use the stored
credentials through an Oracle Database client library without needing a
password.

Prevent unauthorized operating system users from accessing the wallet. Wallet
files should be well secured using OS directory and file security
(i.e., chmod, chown). This approach ensures that only authorized users and
processes have the necessary permissions to the wallet, enhancing overall
security and aligning with the principle of least privilege.

The wallet files can further be obfuscated by making the wallet directory a
hidden directory (starting with a period).

--------------------------------------------------------------------------------
Managing Secure External Password Store Credentials
--------------------------------------------------------------------------------

Database credentials in a Secure External Password Store can be modified
or deleted using the mkstore command.

    1.  Modifying Database Credentials

        How to modify a username/password pair:

        ------------------------------------------------------------------------
        mkstore -wrl <wallet_location> -modifyCredential <db_alias> <username> <password>
        ------------------------------------------------------------------------

        For example:

        ------------------------------------------------------------------------
        $ mkstore -wrl /home/dbadmin/.private/wallet -modifyCredential DATADB dbadmin <new-password>
        ------------------------------------------------------------------------

    2.  Deleting Database Credentials

        How to delete a credential:

        ------------------------------------------------------------------------
        mkstore -wrl /path/to/wallet -deleteCredential <db_alias>
        ------------------------------------------------------------------------

        For example:

        ------------------------------------------------------------------------
        $ mkstore -wrl /home/dbadmin/.private/wallet -deleteCredential DATADB
        ------------------------------------------------------------------------

    3.  List Database Credentials

        ------------------------------------------------------------------------
        $ mkstore -wrl /home/dbadmin/.private/wallet -listCredential
        ------------------------------------------------------------------------
            
    4.  Listing Entry Values

        ------------------------------------------------------------------------
        $ mkstore -wrl /home/dbadmin/.private/wallet -viewEntry oracle.security.client.connect_string1
        $ mkstore -wrl /home/dbadmin/.private/wallet -viewEntry oracle.security.client.username1
        $ mkstore -wrl /home/dbadmin/.private/wallet -viewEntry oracle.security.client.password1
        ------------------------------------------------------------------------

    5.  Modifying Entry Values

        ------------------------------------------------------------------------
        $ mkstore -wrl /home/dbadmin/.private/wallet -modifyEntry oracle.security.client.password1 <new-password>
        ------------------------------------------------------------------------

--------------------------------------------------------------------------------
Best Practices
--------------------------------------------------------------------------------

    1. Use Strong Passwords

       Ensure that strong, complex passwords are set for Oracle Wallets to
       enhance security.

    2. Regularly Rotate Wallet Passwords

       Implement a policy to periodically rotate wallet passwords for continued
       security.

    3. Backup Wallets

       Regularly back up Oracle Wallets to prevent data loss and facilitate
       recovery in case of issues.

    4. Document Wallet Details

       Maintain documentation that includes wallet names, passwords, and SEPS
       configurations for future reference.
