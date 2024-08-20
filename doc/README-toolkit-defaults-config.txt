================================================================================
                       README toolkit-defaults-config.txt
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Synopsis
    [*] Managing User-Editable Configuration Files in Git
    [*] File Format
    [*] Section and Name/Value Definitions

--------------------------------------------------------------------------------
Synopsis
--------------------------------------------------------------------------------

The Unix/Linux scripts in the 'bin/' directory of the "Oracle DBA Toolkit"
support command line parameters for increased flexibility and customization.

In addition to command line parameters, users can provide default values for
some of the key parameters in the 'conf/toolkit-defaults.conf' configuration
file, offering further flexibility and ease of use in the scripts.

Note: Options supplied on the command line take precedence over those specified
      in the configuration file.

The purpose of this note is to provide detailed information about the specific
options defined in the 'conf/toolkit-defaults.conf' configuration file.

--------------------------------------------------------------------------------
Managing User-Editable Configuration Files in Git
--------------------------------------------------------------------------------

The 'conf/toolkit-defaults.conf' file is a user-updatable configuration file
that can be excluded from tracking in Git, enabling users to customize local
settings without affecting the repository. Excluding the configuration file will
allow customizations to the default configuration file that will not be
overwritten when performing a 'git pull' operation.

After cloning the "Oracle DBA Toolkit", exclude the default configuration file
from tracking in Git:

    $ git update-index --assume-unchanged conf/toolkit-defaults.conf

To start tracking changes again, you can undo the previous command using:

    $ git update-index --no-assume-unchanged conf/toolkit-defaults.conf

To view files for which change tracking is disabled (Unix/Linux):

    $ git ls-files -v | grep ^[h]
    h conf/toolkit-defaults.conf

In Windows:

    C:\> git ls-files -v | find "h "

--------------------------------------------------------------------------------
File Format
--------------------------------------------------------------------------------

The 'conf/toolkit-defaults.conf' configuration file follows an INI file format,
with settings organized into sections and specified as name=value pairs.

For example:

    [Section1]
    key1=value1
    key2=value2
    key3=value3

    [Section2]
    keyA=valueA
    keyB=valueB
    keyC=valueC

--------------------------------------------------------------------------------
Section and Name/Value Definitions
--------------------------------------------------------------------------------

This section provides an overview of the configuration file's structure,
explaining how sections and name/value pairs are used to define settings.

--------------------------------------------------------------------------------

[script-options]
log_file_retain_days=[n]            # Number of days to retain log files.
send_email=[0|1]                    # Set 'send_email' to 1 to send email of
                                    #  results. Set to 0 to disable email.
prompt=[0|1]                        # Set 'prompt' to 0 to disable
                                    #  acknowledgement prompt (non-interactive).
                                    #  set to 1 to prompt (interactive).
debug=[0|1]                         # Set 'debug' to 1 to enable debug mode. In
                                    #  debug mode, no changes are performed.
                                    #  Used for debugging purposes.

--------------------------------------------------------------------------------

[organization]
organization_name="Company Name"    # Organization name; Note: No commas!

--------------------------------------------------------------------------------

[email]
email_recipient_list="<email1> <email2>"
                                    # List all administrative email addresses
                                    #  who will be responsible for monitoring
                                    #  and receiving email from this script.
                                    #  Multiple email addresses should all be
                                    #  listed in double-quotes separated by a
                                    #  single space.
email_from="${organization_name} Database Support <email>"
                                    # The variable 'email_from' is used to store
                                    #  the email address from which an email is
                                    #  being sent.
email_replyto="${organization_name} Database Support <email>"
                                    # The variable 'email_replyto' is used to
                                    #  store the email address to which replies
                                    #  should be sent.
email_to_name="${organization_name} Database Support"
                                    # The variable 'email_to_name' is used to
                                    #  store the name of the recipient of an
                                    #  email.
email_color="#000000"               # Font color in hexadecimal format.
email_bgcolor="#FFFFFF"             # Background color in hexadecimal format.
email_headercolor="#003366"         # Headers color in hexadecimal format.

--------------------------------------------------------------------------------

[oracle-options]                    # Default options specific to Oracle.
sqlnet_wallet_dir="directory-name"  # The directory location of the sqlnet.ora
                                    #  file for Oracle Wallet. When using an
                                    #  Oracle wallet for Secure External
                                    #  Password Store (SEPS) to store
                                    #  default credentials for connecting to a
                                    #  database, the sqlnet.ora file contains
                                    #  configuration options for Oracle Net
                                    #  Services, including "WALLET_LOCATION" and
                                    #  other settings related to the Oracle
                                    #  Wallet. For example:
                                    #  "/home/dbadmin/.private/network".

--------------------------------------------------------------------------------

[rman-backup]                       # Default options for Oracle RMAN backup
                                    #  script: bin/rman-backup.sh.
rman_compress_backup=[0|1]          # Set 'rman_compress_backup' to 1 to
                                    #  compress backupset. Set to 0 to disable
                                    #  compression.
minimum_oracle_version=[n]          # Minimum required Oracle version. For
                                    #  example, for Oracle Database 12c, set to
                                    #  12.

--------------------------------------------------------------------------------

[dpump-backup]                      # Default options for Oracle Data Pump
                                    #  backup script: bin/dpump-backup.sh.
dumpdir=DPUMP_DUMP_DIR              # Oracle "Directory Name" used by Data Pump
                                    #  to write the dump file to on the database
                                    #  server.
logdir=DPUMP_LOG_DIR                # Oracle "Directory Name" used by Data Pump
                                    #  to write the log file to on the database
                                    #  server.
retention=[n]                       # Default number of days to keep backup dump
                                    #  files.
consistent_export=[0|1]             # Set 'consistent_export' to 1 to perform a
                                    #  consistent Oracle Data Pump export using
                                    #  dbms_flashback.get_system_change_number.
                                    #  Set to 0 to perform a non-consistent
                                    #  export
minimum_oracle_version=[n]          # Minimum required Oracle version. For
                                    #  example, for Oracle Database 12c, set to
                                    #  12.
