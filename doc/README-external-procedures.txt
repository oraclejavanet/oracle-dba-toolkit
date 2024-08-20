================================================================================
                           Oracle External Procedures
================================================================================

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

Oracle External Procedures (EXTPROC) is a feature that extends the functionality
of Oracle PL/SQL by allowing developers and database administrators to integrate
external programs and languages. EXTPROC enables users to incorporate code
written in languages such as C, C++, Java, or others directly into an Oracle
Database environment, enhancing its capabilities and enriching its flexibility.

The "Oracle DBA Toolkit" provides a sample program written in C and a BASH shell
script for compiling and building it as a shared library to be used as an
external procedure. The provided C program serves as a hands-on illustration and
demonstrates the practical implementation of Oracle External Procedures.

The sample C program can be found in 'oracle-dba-toolkit/extproc/example':

    * factorial.c
    * factorial.h
    * main.c

Use the 'oracle-dba-toolkit/extproc/example/build.sh' shell script to compile
and build the shared library (factorial.so) for the included PL/SQL external
procedure application.

--------------------------------------------------------------------------------
Prerequisites
--------------------------------------------------------------------------------

1.  The following software installed on the local machine:

        * Oracle Database 8i (8.1.7) or higher
        * GNU Compiler Collection (GCC)
        
--------------------------------------------------------------------------------
About Oracle External Procedures
--------------------------------------------------------------------------------

Oracle PL/SQL is a powerful programming language that offers a number of
benefits for developers and database administrators such as tight integration
with the Oracle Database, robust support for transaction management, and a
powerful exception-handling mechanism. PL/SQL serves various purposes, with a
specialization in SQL transaction processing. However, some tasks are more
quickly or easily done in a lower-level language such as C, which is more
efficient at machine-precision calculations. For example, a Fast Fourier
Transform (FFT) routine written in C runs faster than one written in PL/SQL.

To support such special-purpose processing, PL/SQL provides an interface
for calling routines written in other languages known as "External Procedures"
(EXTPROC).

EXTPROC is a feature in Oracle Database that allows developers and database
administrators to call external procedures or functions written in a language
other than PL/SQL. The primary use case for EXTPROC is to integrate non-PL/SQL
code, typically written in a lower-level language such as C, C++, or Java, with
the Oracle Database.

Developers can extend Oracle PL/SQL by creating shared objects (dynamic linked
libraries or DDL's) that contains the code in a function for what they want to
achieve. This is accomplished by registering the shared object with the Oracle
server using the CREATE LIBRARY statement. Once registered, the functions or
procedures can be called from within PL/SQL or SQL.

--------------------------------------------------------------------------------
Setup Oracle extproc Environment (Release 12.1 and higher)
--------------------------------------------------------------------------------

Configure the $ORACLE_HOME/hs/admin/extproc.ora file on the Oracle Database
server to point to the location of the shared library file(s).

For example:

    SET EXTPROC_DLLS=ONLY:/opt/oracle-dba-toolkit/lib/extproc/factorial.so
    SET LD_LIBRARY_PATH=/u01/app/oracle/product/19.0.0/dbhome_1/lib

    . . .

    TRACE_LEVEL=ON

After modifying extproc.ora, it may be necessary to restart the Oracle Listener:

    $ lsnrctl stop
    $ lsnrctl start

extproc.ora sets environment variables for the extproc daemon, which is used to
execute code for external stored procedures, and for procedures themselves.

The one environment variable recognized by extproc itself is EXTPROC_DLLS (shown
above), which determines the locations where the daemon looks for shared
libraries. If set to 'ONLY:<path>', extproc will not look in $ORACLE_HOME/bin or
$ORACLE_HOME/lib.

Any other variables set in extproc.ora are simply passed on to the environment
where the external code runs, so they would be specific to each library.

--------------------------------------------------------------------------------
Setup Oracle extproc Environment (Release 8.1.7 to 11.2)
--------------------------------------------------------------------------------

1.  Oracle Database uses an external procedure agent named 'extproc' to support
    external procedures.

2.  Configure the Oracle Listener file on the local database machine.

    For example:

    #
    # $ORACLE_HOME/network/admin/listener.ora
    # 

    SID_LIST_LISTENER =
      (SID_LIST =
        (SID_DESC =
          (SID_NAME = PLSExtProc)
          (ORACLE_HOME = /u01/app/oracle/product/11.2.0.4/dbhome_1)
          (PROGRAM = extproc)
          (ENVS = "EXTPROC_DLLS=ONLY:/opt/oracle-dba-toolkit/lib/extproc/factorial.so",
                  "LD_LIBRARY_PATH=/u01/app/oracle/product/11.2.0.4/dbhome_1/lib"
          )
        )
      )
    
    LISTENER =
      (DESCRIPTION_LIST =
        (DESCRIPTION =
          (ADDRESS = (PROTOCOL = TCP)(HOST = oranode11.acmeindustries.com)(PORT = 1521))
          (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
        )
      )

    ADR_BASE_LISTENER = /u01/app/oracle

3.  Restart the Oracle Listener:

    $ lsnrctl stop
    $ lsnrctl start

4.  A valid TNS entry is required in the $ORACLE_HOME/network/admin/tnsnames.ora
    file on the local database machine.

    For example:

    #
    # $ORACLE_HOME/network/admin/tnsnames.ora
    #

    EXTPROC_CONNECTION_DATA.ACMEINDUSTRIES.COM =
      (DESCRIPTION =
        (ADDRESS_LIST =
          (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
        )
        (CONNECT_DATA =
          (SERVER = DEDICATED)
          (SERVICE_NAME = PLSExtProc)
        )
      )

--------------------------------------------------------------------------------
Setup
--------------------------------------------------------------------------------

The 'oracle-dba-toolkit/extproc/example/build.sh' shell script performs the
following steps:

1.  Compile and build the shared library 'factorial.so' for the PL/SQL
    external procedures demo (Linux).

        # Linux
        $ gcc -Wall -Wextra -Wpedantic -std=c99 -m64 -fPIC -g -c factorial.c
        $ gcc -shared -m64 -o factorial.so factorial.o
        $ chmod 775 factorial.so

        # SunOS (Oracle Solaris)
        $ gcc -Wall -Wextra -std=c99 -m64 -fPIC -g -c factorial.c
        $ gcc -shared -m64 -o factorial.so factorial.o
        $ chmod 775 factorial.so

        +-------------------+             +--------------------+
        |    factorial.c    |   ------>   |    factorial.so    |
        +-------------------+             +--------------------+
        source code                       shared library

2.  Copy shared library to destination operating system path.

        $ mkdir -p /opt/oracle-dba-toolkit/lib/extproc
        $ cp factorial.so /opt/oracle-dba-toolkit/lib/extproc/factorial.so

        +--------------------+             +--------------------------------------------------------+
        |    factorial.so    |   ------>   |    /opt/oracle-dba-toolkit/lib/extproc/factorial.so    |
        +--------------------+             +--------------------------------------------------------+
        shared library                     destination os path

3.  After successfully building the shared library and copying it to the
    destination OS path, create an Oracle library definition named 'EXAMPLE_LIB'
    which is an Oracle schema object associated with the operating system shared
    library.

        SQL> CONNECT scott@"//datanode:1521/datadb.acmeindustries.com"
        SQL> CREATE OR REPLACE LIBRARY example_lib
                AS '/opt/oracle-dba-toolkit/lib/extproc/factorial.so';
             /

        +--------------------------------------------------------+             +------------------------+
        |    /opt/oracle-dba-toolkit/lib/extproc/factorial.so    |   ------>   |    SCOTT.EXAMPLE_LIB   |
        +--------------------------------------------------------+             +------------------------+
        destination os path                                                     oracle library definition

    Note: The default paths searched by the extproc daemon for loading the
          required shared library are $ORACLE_HOME/bin and $ORACLE_HOME/lib.

4.  Create a PL/SQL package specification and body including the procedures and
    functions (wrapper procedures and wrapper functions) referencing the Oracle
    library definition named 'example_lib'.

        SQL> CONNECT scott@"//datanode:1521/datadb.acmeindustries.com"
             
        SQL> CREATE OR REPLACE PACKAGE example_pkg AS

                 FUNCTION fact(
                     n   IN PLS_INTEGER
                 ) RETURN DOUBLE PRECISION;

             END example_pkg;
             /

        SQL> CREATE OR REPLACE PACKAGE BODY example_pkg AS

                 FUNCTION fact(
                     n   IN PLS_INTEGER
                 ) RETURN DOUBLE PRECISION AS
                     EXTERNAL
                         LIBRARY example_lib                 -- Oracle library definition
                         NAME "fact"                         -- function name in library, quotes preserve lower case
                         LANGUAGE C                          -- language of routine
                         PARAMETERS (n ub4, RETURN double);  -- map n to unsigned 4-byte (unsigned int)
                                                             -- map return value to a double
             END example_pkg;
             /

            SQL> DESC SCOTT.EXAMPLE_PKG
            FUNCTION FACT RETURNS NUMBER(126)
            Argument Name                  Type                    In/Out Default?
            ------------------------------ ----------------------- ------ --------
            N                              BINARY_INTEGER          IN

        +-------------------------+             +------------------------------+
        |    SCOTT.EXAMPLE_LIB    |   ------>   |    SCOTT.EXAMPLE_PKG.FACT    |
        +-------------------------+             +------------------------------+
        oracle library definition               oracle pl/sql wrapper procedures/functions

5.  Test external procedures by calling the PL/SQL specification procedures and
    functions (wrapper procedures and wrapper functions).

        SQL> CONNECT scott@"//datanode:1521/datadb.acmeindustries.com"
        SQL> SET SERVEROUTPUT ON
        SQL> BEGIN
                 DBMS_OUTPUT.put(chr(10));
                 DBMS_OUTPUT.PUT_LINE('Current session: ' ||
                                      UPPER(SYS_CONTEXT('USERENV', 'CURRENT_USER')) || '@' ||
                                      UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')));
                 DBMS_OUTPUT.put(chr(10));
                 DBMS_OUTPUT.put_line('Calculate factorials using an Oracle External Procedure (EXTPROC)');
                 DBMS_OUTPUT.put_line('written in C.');
                 DBMS_OUTPUT.put(chr(10));

                 FOR n IN 0..20
                 LOOP
                     DBMS_OUTPUT.put_line(n || '! = ' || EXAMPLE_PKG.fact(n));
                 END LOOP;
             END;
             /

        +--------------+
        |    OUTPUT    |
        +--------------+

        Current session: SCOTT@DATADB

        Calculate factorials using an Oracle External Procedure (EXTPROC)
        written in C.

        0! = 1
        1! = 1
        2! = 2
        3! = 6
        4! = 24
        5! = 120
        6! = 720
        7! = 5040
        8! = 40320
        9! = 362880
        10! = 3628800
        11! = 39916800
        12! = 479001600
        13! = 6227020800
        14! = 87178291200
        15! = 1307674368000
        16! = 20922789888000
        17! = 355687428096000
        18! = 6402373705728000
        19! = 121645100408832000
        20! = 2432902008176640000

        PL/SQL procedure successfully completed.

--------------------------------------------------------------------------------
Notes
--------------------------------------------------------------------------------

1.  Console Output

    If the shared library produces any output to the console, it will not be
    displayed. All you should see is "PL/SQL procedure successfully completed."
    which is often times good enough for testing and proves extproc is working
    properly. To see the output, redirect the output to a text file. For example:

        SQL> EXEC shell('/bin/ls>output.txt');

    If there is no output, supply a full path to an output file:

        SQL> EXEC shell('/bin/ls>/u01/app/oracle/output.txt');

2.  Trace extproc Process

    Once the PL/SQL block execution starts, you can trace the extproc process by
    listing the processes. The extproc process is active until the end of the
    session.

        [oracle@datanode ~]$ ps -ef | grep extproc | grep -v 'grep'
        oracle   2662968       1  0 17:16 ?        00:00:00 /u01/app/oracle/product/19.0.0/dbhome_1/bin/extproc (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=BEQ)))

    Additionally, if TRACE_LEVEL is enabled in
    $ORACLE_HOME/hs/admin/extproc.ora, the extproc process will write trace
    files to $ORACLE_HOME/hs/log.

3.  External Procedures Restrictions

    * The feature is limited to the platforms that support dynamically linked
      libraries

    * The extproc process and PL/SQL procedure need to be on the same host
    
    * The library clause cannot point to a remote location through a database
      link
    
    * The maximum number of parameters to an external procedure is 128
    
    * Parameters of cursor variable types are not supported with external
      procedures

4.  The default configuration for external procedures does not require a network
    listener to work with Oracle Database and the extproc agent. The extproc
    agent is spawned directly by Oracle Database and eliminates the risks that
    the extproc agent might be spawned by Oracle Listener unexpectedly. This
    default configuration is recommended for maximum security.
    
    You can change the default configuration for external procedures and have
    the extproc agent spawned by Oracle Listener. To do this, you must perform
    additional network configuration steps.
    
    Having the extproc agent spawned by Oracle Listener is necessary if you use
    the AGENT clause of the LIBRARY specification or the AGENT IN clause of the
    PROCEDURE specification such that you can redirect external procedures to a
    different extproc agent.

5.  Securing External Procedures with Oracle Database 12c

    The Oracle Database creates the extproc process and runs under the operating
    system user that starts the listener or runs an Oracle server process. Quite
    often, you will see the extproc process running as the oracle user. The
    extproc process is not physically associated with the Oracle Database.

    Oracle Database 12c enables enhanced security for extproc by authenticating
    it against a user-supplied credential. This new feature allows the creation
    of a user credential and associates it with the PL/SQL library object.
    Whenever the application calls an external procedure, the extproc process
    authenticates the connection before loading the shared library.

    The DBMS_CREDENTIAL package allows the configuration of the credential
    through member subprograms. The CREATE LIBRARY statement has been enhanced
    for credential specification. A new environment variable, 
    ENFORCE_CREDENTIAL, can be specified in extproc.ora to control the
    authentication by the extproc process. The default value of the parameter is
    FALSE. Another new environment variable, GLOBAL_EXTPROC_CREDENTIAL, serves
    as the default credential and is only used when the credential is not
    specified for a library. If ENFORCE_CREDENTIAL is FALSE and no credential
    has been defined in the PL/SQL library, there will be no user
    authentication; this means the extproc process will authenticate by using
    the privileges of the user running the Oracle server.

    The following PL/SQL block creates a credential by using
    DBMS_CREDENTIAL.CREATE_CREDENTIAL. This credential is built using the SCOTT
    user:

        BEGIN
            DBMS_CREDENTIAL.CREATE_CREDENTIAL (
                credential_name   => 'datanode_auth',
                user_name         => 'scott',
                password          => 'tiger');
        END;
        /

    The Oracle library definition will include an additional CREDENTIAL clause:

        CREATE OR REPLACE LIBRARY example_lib
            AS '/opt/oracle-dba-toolkit/lib/extproc/factorial.so'
            CREDENTIAL datanode_auth;
        /

    When the extproc process reads the call specification and finds the shared
    library with a secured credential, it authenticates the library on behalf of
    the credential and then loads it.

--------------------------------------------------------------------------------
Known Issues
--------------------------------------------------------------------------------

1.  ORA-28595: Extproc agent : Invalid DLL Path

    Possible solutions are:
    
        * The most common reason for this error is that the Oracle External
          Procedure Agent (extproc) is unable to access the shared library
          files. Use the 'EXTPROC_DLLS' parameter in the
          $ORACLE_HOME/hs/admin/extproc.ora configuration file to specify the
          shared libraries (*.so) or dynamic link libraries (DLLs) that contain
          the external procedures.

          Review the following sections provided in this note:

            > Setup Oracle extproc Environment (Release 8.1.7 to 11.2)
            > Setup Oracle extproc Environment (Release 12.1 and higher)

        * Use default configuration for better security and let the database
          spawn the extproc agent and use the $ORACLE_HOME/hs/admin/extproc.ora
          to specify all the settings (i.e., LD_LIBRARY_PATH, EXTPROC_DLLS,
          etc).
        
        * For some reason, if the extproc needs to be spawned by the listener,
          then use a different service name other than "EXTPROC_CONNECTION_DATA"
          and use the AGENT/AGENT IN clause with the library or PL/SQL
          specification.

2.  stats.c:32:5: error: ‘for’ loop initial declarations are only allowed in C99 mode

    Error Description

        The error message indicates that the use of variable declarations within
        the initialization part of a for loop is not allowed in the current
        compilation mode (e.g., C89 mode).

        For example:

            for (int i = 0; i < 10; ++i) {
                // Your loop code here
            }

    Solution Description

        To address this issue, you can do one of the following:

            1.  Compile in C99 mode:

                The -std=c99 option is used to specify the language standard to
                be used for compiling C code. Specifically, it instructs the
                compiler to adhere to the C99 standard, which is the 1999
                revision of the C programming language standard.

                Use the -std=c99 option when compiling your code to enable
                support for C99 features, including variable declarations within
                the initialization part of a for loop. For example:

                    gcc -Wall -std=c99 -fPIC -c stats.c

            2.  Move variable declarations outside the loop:

                If changing the compilation mode is not an option, you can move
                the variable declarations outside the for loop. For example:

                    int i; // Move the declaration outside the loop
                    for (i = 0; i < 10; ++i) {
                        // Your loop code here
                    }
                
                This way, you comply with the C89 standard, which does not allow
                variable declarations within the initialization part of a for
                loop.

--------------------------------------------------------------------------------
References
--------------------------------------------------------------------------------

    * Steps to Create and Run a Sample External Procedure Program on Unix (Doc ID 312564.1)
        https://support.oracle.com/epmos/faces/DocumentDisplay?id=312564.1

    * Configuring extproc 11g and higher in a RAC environment with SCAN (Doc ID 1608372.1)
        https://support.oracle.com/epmos/faces/DocumentDisplay?id=1608372.1

    * Getting 'ORA-28595: Extproc Agent : Invalid DLL Path' With External Procedure Call After Upgrade to 12.2 (Doc ID 2424136.1)
        https://support.oracle.com/epmos/faces/DocumentDisplay?id=2424136.1

    * Securing External Procedures with Oracle Database 12c
        https://learning.oreilly.com/library/view/advanced-oracle-pl-sql/9781785284809/ch05s04.html

    * Oracle - spawn extproc by listener or database
        https://westzq1.github.io/oracle/2019/02/24/extproc-use-different-user.html

    * Access to external executables must be disabled or restricted
        https://www.stigviewer.com/stig/oracle_database_12c/2019-09-26/finding/V-61685

    * Extending the SQL and PL/SQL with custom external functions and procedures
        https://medium.com/codex/extending-the-sql-and-pl-sql-with-custom-external-functions-and-procedures-214067761061
