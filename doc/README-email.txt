================================================================================
    Setup Email Functionality on a Database Server for Script Notifications
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Overview
    [*] About Postfix
    [*] About Sendmail
    [*] Prerequisites
    [*] Linux (RHEL)
    [*] Linux (Debian / Ubuntu)
    [*] Oracle Solaris

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

Many of the database maintenance scripts found in the /bin directory of the
Oracle DBA Toolkit contains functionality to send email notifications or alerts
regarding the status of database operations, such as backups, performance
monitoring, and error handling.

This guide explains how to set up and configure email functionality on a target
database server to send email notifications, such as the results of a shell
script. This can be helpful for monitoring and managing scripts that run on the
database server.

--------------------------------------------------------------------------------
About Postfix
--------------------------------------------------------------------------------

Postfix is a flexible mail server that is available on most Linux distribution.
Though a full feature mail server, Postfix can also be used as a simple relay
host to another mail server, or smart host (smarthost).

--------------------------------------------------------------------------------
About Sendmail
--------------------------------------------------------------------------------

Sendmail is a feature-rich MTA (Mail Transfer Agent) that uses the SMTP protocol
for sending mail. Though Sendmail has been replaced by postfix in modern RHEL
versions, it is widely used in RHEL 5 or its earlier version. Sendmail is
recommended by most of the system administrator as an MTA(Mail transfer agent)
server over other MTAs.

--------------------------------------------------------------------------------
Prerequisites
--------------------------------------------------------------------------------

1.  Access to an SMTP server (e.g., Gmail, Outlook, or a corporate SMTP server).

2.  Basic understanding of scripting and command-line interfaces.

--------------------------------------------------------------------------------
Linux (RHEL)
--------------------------------------------------------------------------------

Sending email from a shell script in Linux is a quick and easy way to automate
sending notifications or reports. To do this, you will need to use the sendmail
or mail command to do the actual sending of the email.

This section provides configuration instructions to setup and configure Postfix
and Sendmail to send email from the command line in Linux RHEL and other RHEL
derivatives such as Oracle Linux, Rocky Linux, and CentOS.

Install and Configure Email Packages:

1.  Install Postfix and the SASL authentication framework.

    [RHEL 9/8]
    $ sudo dnf install -y postfix cyrus-sasl-plain

    [RHEL 7]
    $ sudo yum install -y postfix cyrus-sasl-plain

    Note:   If the Linux packages are being reinstalled, first remove them:

            $ yum remove postfix sendmail mailx mutt
            $ yum autoremove

2.  Install Sendmail and any other mail client packages.

    [RHEL 9]
    $ sudo dnf install -y sendmail mutt s-nail

    [RHEL 8/7]
    $ sudo yum install -y sendmail mailx mutt

    Note:   According to Bugzilla Bug 2001537 "mailx -> s-nail replacement in
            CentOS Stream 9", mailx was replaced by s-nail. There's also a
            reference to the same in the Red Hat's "Considerations in adopting
            RHEL 9" - Appendix A. Change to packages - Package replacements.

            https://bugzilla.redhat.com/show_bug.cgi?id=2001537
            https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/considerations_in_adopting_rhel_9/assembly_changes-to-packages_considerations-in-adopting-rhel-9

3.  Restart Postfix to detect the SASL framework.

    $ sudo systemctl restart postfix
    $ sudo systemctl is-active postfix
    active

4.  Start Postfix on boot.

    $ sudo systemctl enable postfix

5.  Modify the /etc/postfix/main.cf file.
    
    Paste the following at the end of the file using your SMTP server
    (e.g., smtp.gmail.com):

    +----------------------+
    | /etc/postfix/main.cf |
    |---------------------------------------------------------------------------
    | . . .
    | 
    | # [custom settings]
    | relayhost = [smtp.gmail.com]:587
    | smtp_use_tls = yes
    | smtp_sasl_auth_enable = yes
    | smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    | #smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
    | smtp_sasl_security_options = noanonymous
    | smtp_sasl_tls_security_options = noanonymous
    +---------------------------------------------------------------------------

6.  Configure Postfix SASL credentials.
    
    Add the SMTP credentials for authentication. Create the file
    "/etc/postfix/sasl_passwd":

    +--------------------------+
    | /etc/postfix/sasl_passwd |
    |---------------------------------------------------------------------------
    | [smtp.gmail.com]:587 username:password
    +---------------------------------------------------------------------------

    Note:   When using Gmail for your SMTP server (smtp.gmail.com), replace
            username with your Gmail ID and password with your Gmail Password.

7.  Create a Postfix lookup table from the sasl_passwd text file by running the
    following command:

    $ sudo postmap /etc/postfix/sasl_passwd

    Note:   smtp_tls_CAfile

            The Postfix configuration parameter smtp_tls_CAfile may exist in
            several places in the /etc/postfix/main.cf file. This parameter
            specifies the full pathname of a file containing CA certificates of
            root CA's trusted to sign either remote SMTP server certificates or
            intermediate CA certificates. This is needed if you want it to be
            able to use TLS when sending mail to other servers.

            The following warning message will be displayed if duplicate entries
            are found in /etc/postfix/main.cf:

                postmap: warning: /etc/postfix/main.cf, line 745: overriding earlier entry: smtp_tls_CAfile=/etc/pki/tls/certs/ca-bundle.crt

            It's often the case this parameter will be set to the files
            /etc/pki/tls/certs/ca-bundle.crt or /etc/ssl/certs/ca-bundle.crt. These files are the same.

            Comment out one of the entries for smtp_tls_CAfile.

Send Test Email:

    $ echo "This is test mail." | mail -s "message" dba@acmeindustries.com

    or

    $ echo -e "To: dba@acmeindustries.com\nSubject: Email Test\nThis is a testing email from the local domain\n" | /usr/lib/sendmail -bm -t -v

    or

    $ /usr/lib/sendmail -v dba@acmeindustries.com < ~/.bash_profile

--------------------------------------------------------------------------------
Linux (Debian / Ubuntu)
--------------------------------------------------------------------------------

Sending email from a shell script in Linux is a quick and easy way to automate
sending notifications or reports. To do this, you will need to use the sendmail
or mail command to do the actual sending of the email.

This section provides configuration instructions to setup and configure Postfix
and Sendmail to send email from the command line in Linux (Debian / Ubuntu).

1.  Update the system.
    
    $ sudo apt update
    $ sudo apt-get upgrade -y
    
2.  Install Postfix and the command-line tools for sending, receiving, and
    managing email.

    $ sudo apt install -y mailutils

    * When prompted, select the "General mail configuration type": "Internet Site".
    * Next, supply the "System mail name" which for this configuration is the
      FQDN for the machine. For example: "erpprod.acme.com".

    Note:   When supplying the "System mail name:", it is not necessary to enter
            the full name of your domain. It will be valid outside of your
            network. The name will be used in the "header" of the message and
            perhaps you will need it to identify it in the mail server logs.

3.  Install pluggable authentication modules.

    $ sudo apt install -y libsasl2-modules postfix

4.  Configure myhostname.

    Check/verify myhostname in the /etc/postfix/main.cf file.

    +----------------------+
    | /etc/postfix/main.cf |
    |---------------------------------------------------------------------------
    | . . .
    |
    |  myhostname = erpprod.acme.com
    |
    | . . .
    +---------------------------------------------------------------------------

5.  Setup the relay server.

    Again, modify the /etc/postfix/main.cf file.
    
    Paste the following at the end of the file using your SMTP server
    (e.g., smtp.gmail.com):

    +----------------------+
    | /etc/postfix/main.cf |
    |---------------------------------------------------------------------------
    | . . .
    |
    | # [custom settings]
    | 
    | # Enable auth
    | smtp_sasl_auth_enable = yes
    | 
    | # Set username and password
    | smtp_sasl_password_maps = static:YOUR-SMTP-USER-NAME-HERE:YOUR-SMTP-SERVER-PASSWORD-HERE
    | smtp_sasl_security_options = noanonymous
    | 
    | # Turn on tls encryption 
    | smtp_tls_security_level = encrypt
    | header_size_limit = 4096000
    | 
    | # Set external SMTP relay host here IP or hostname accepted along with a port number. 
    | relayhost = [YOUR-SMTP-SERVER-IP-HERE]:587
    | 
    | # accept email from the database server only (adjust to match your VPC/VLAN etc)
    | inet_interfaces = 127.0.0.1
    +---------------------------------------------------------------------------

    Note:   Comment out any previous declarations/duplicates found above
            "custom settings". For example:

            #smtp_tls_security_level=may
            #relayhost =
            #inet_interfaces = all

6.  Restart Postfix.

    $ sudo systemctl restart postfix

7.  Verify that TCP port #25 is in listing state on the appropriate
    interface(s).

    $ sudo ss -tulpn | grep 25
    tcp   LISTEN 0      100                             127.0.0.1:25         0.0.0.0:*    users:(("master",pid=8317,fd=13))

    $ sudo netstat -tulpn | grep :25
    tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      8317/master

--------------------------------------------------------------------------------
Oracle Solaris
--------------------------------------------------------------------------------

Sending email from a shell script in Oracle Solaris is a quick and easy way to
automate sending notifications or reports. To do this, you will need to use the
sendmail or mail command to do the actual sending of the email.

This section provides configuration instructions to setup and configure Postfix
and Sendmail to send email from the command line in Oracle Solaris.

The instructions will explain how to configure Postfix MTA to send email using
an external cloud-based SMTP server (with username: password). The target server
will be configured to use postfix as the relay server (smarthost).

The version of Postfix that is delivered in the Solaris 11.4 release is built
with SASL support. The package dependencies will ensure the SASL packages are
automatically installed if Postfix is installed.

Prerequisites:

1.  Verify Sendmail is installed.

    $ pkg list pkg:/service/network/smtp/sendmail
    NAME (PUBLISHER)                                  VERSION                    IFO
    service/network/smtp/sendmail                     8.15.2-11.4.42.0.0.111.0   i--

2.  Verify Sendmail is compiled with SASL support (SASLv2).

    $ /usr/lib/sendmail -d0 -bt < /dev/null
    Version 8.15.2+Sun
    Compiled with: DNSMAP LDAPMAP LOG MAP_REGEX MATCHGECOS MILTER MIME7TO8
                    MIME8TO7 NAMED_BIND NDBM NETINET NETINET6 NETUNIX NEWDB NIS
                    PIPELINING SASLv2 SCANF STARTTLS TCPWRAPPERS USERDB
                    USE_LDAP_INIT XDEBUG

    ============ SYSTEM IDENTITY (after readcf) ============
        (short domain name) $w = orasolnode19
    (canonical domain name) $j = orasolnode19.acmeindustries.com
            (subdomain name) $m = acmeindustries.com
                (node name) $k = orasolnode19
    ========================================================

    ADDRESS TEST MODE (ruleset 3 NOT automatically invoked)
    Enter <ruleset> <address>
    >

    $ ldd /usr/lib/sendmail | grep sasl
            libsasl2.so.3 =>         /usr/lib/64/libsasl2.so.3

3.  Verify status of Sendmail service.

    $ svcs sendmail
    STATE          STIME           FMRI
    online         06:46:52        svc:/network/smtp:sendmail

    $ sudo svcs -x sendmail
    svc:/network/smtp:sendmail (sendmail SMTP mail transfer agent)
    State: online since January 17, 2024 at  6:46:52 AM EST
    See: sendmail(1M)
    See: /var/svc/log/network-smtp:sendmail.log
    Impact: None.

4.  Verify status of Sendmail client service.

    $ svcs sendmail-client
    STATE          STIME           FMRI
    online         06:46:55        svc:/network/sendmail-client:default

    $ sudo svcs -x sendmail-client
    svc:/network/sendmail-client:default (sendmail SMTP client queue runner)
    State: online since January 17, 2024 at  6:46:55 AM EST
    See: sendmail(1M)
    See: /var/svc/log/network-sendmail-client:default.log
    Impact: None.

Install Postfix:

1.  Verify Postfix is not installed on the current image.

    $ pkg list postfix

    pkg list: no packages matching the following patterns are installed:
    postfix

2.  Show which publishers provide a version of the Postfix package that can be
    installed in this image.

    $ pkg list -a postfix
    NAME (PUBLISHER)                                  VERSION                    IFO
    service/network/smtp/postfix                      3.2.2-11.4.42.0.0.111.0    ---

3.  Install the Postfix package on the current image.

    $ sudo pkg install postfix

4.  Verify Postfix install.

    $ pkg list postfix
    NAME (PUBLISHER)                                  VERSION                    IFO
    service/network/smtp/postfix                      3.2.2-11.4.42.0.0.111.0    i--

5.  Verify Postfix service is not enabled / running.

    $ svcs postfix
    STATE          STIME           FMRI
    disabled       07:14:11        svc:/network/smtp:postfix

    $ sudo svcs -x postfix
    svc:/network/smtp:postfix (postfix SMTP mail transfer agent)
    State: disabled since January 17, 2024 at  7:14:11 AM EST
    Reason: Disabled by an administrator.
    See: http://support.oracle.com/msg/SMF-8000-05
    See: postfix(1)
    See: /var/svc/log/network-smtp:postfix.log
    Impact: This service is not running.

6.  Verify Postfix is compiled with SASL support (cyrus).

    $ postconf -a
    cyrus        <-----
    dovecot

Upgrade Sendmail to Postfix:

Life is too short for Sendmail!

1.  Disable Sendmail service.

    $ sudo svcadm disable sendmail

2.  Disable Sendmail client.

    $ sudo svcadm disable sendmail-client

3.  Verify Sendmail / Sendmail client services are disabled.

    $ svcs sendmail
    STATE          STIME           FMRI
    disabled       08:26:50        svc:/network/smtp:sendmail

    $ svcs sendmail-client
    STATE          STIME           FMRI
    disabled       08:26:58        svc:/network/sendmail-client:default

4.  Change the Sendmail mediator to the Postfix implementation.

    $ sudo pkg set-mediator -I postfix sendmail
                Packages to change:   3
            Mediators to change:   1
        Create boot environment:  No
    Create backup boot environment: Yes
    PHASE                                          ITEMS
    Removing old actions                             2/2
    Updating modified actions                        5/5
    Updating package state database                 Done
    Updating package cache                           0/0
    Updating image state                            Done
    Creating fast lookup database                   Done
    Updating package cache                           1/1

5.  Configure your domain name.

    /usr/sbin/postconf mydomain=YOUR.DOMAIN

    Note:   You can determine your domain name, YOUR.DOMAIN in the following ways
            based on the decreasing order of preference:

            $ svcprop -cp config/domain dns/client
            svcprop: Couldn't find property group `config/domain' for instance `svc:/network/dns/client:default'.

            $ svcprop -cp config/search dns/client | nawk '{print $1}'
            acmeindustries.com

    For example:

    $ sudo postconf mydomain=acmeindustries.com

    Verify change:

    $ postconf | grep '^my'
    mydestination = $myhostname, localhost.$mydomain, localhost
    mydomain = acmeindustries.com                      <-----
    myhostname = orasolnode19.acmeindustries.com       <-----
    mynetworks = 127.0.0.1/32 192.168.1.244/32         <-----
    mynetworks_style = ${{$compatibility_level} < {2} ? {subnet} : {host}}
    myorigin = $myhostname

6.  Enable the Postfix client.

    $ sudo svcadm enable postfix

7.  Verify status of Postfix client service.

    $ svcs postfix
    STATE          STIME           FMRI
    online         10:30:33        svc:/network/smtp:postfix

    $ sudo svcs -x postfix
    svc:/network/smtp:postfix (postfix SMTP mail transfer agent)
    State: online since January 17, 2024 at 10:30:33 AM EST
    See: postfix(1)
    See: /var/svc/log/network-smtp:postfix.log
    Impact: None.

    Note:   If the Postfix service does not come online, review the log file:

            $ sudo tail -f /var/svc/log/network-smtp:postfix.log 

Configure Postfix:

Configure Postfix to forward mails to a relay host aka smarthost.

1.  Perform a backup of the original Postfix configuration file.

    $ sudo cp /etc/postfix/main.cf /etc/postfix/main_backup_$(date +"%Y%m%d%H%M%S").cf

2.  Modify the /etc/postfix/main.cf file.
    
    Paste the following at the end of the file using your SMTP server
    (e.g., smtp.gmail.com):

    +----------------------+
    | /etc/postfix/main.cf |
    |---------------------------------------------------------------------------
    | . . .
    | 
    | # [custom settings]
    | relayhost = [smtp.gmail.com]:587
    | smtp_use_tls = yes
    | smtp_sasl_auth_enable = yes
    | smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    | #smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
    | smtp_sasl_security_options = noanonymous
    | smtp_sasl_tls_security_options = noanonymous
    +---------------------------------------------------------------------------

3.  Configure Postfix SASL credentials.

    Add the SMTP credentials for authentication. Create the file
    "/etc/postfix/sasl_passwd":

    +--------------------------+
    | /etc/postfix/sasl_passwd |
    |---------------------------------------------------------------------------
    | [smtp.gmail.com]:587 username:password
    +---------------------------------------------------------------------------

    Note:   When using Gmail for your SMTP server (smtp.gmail.com), replace
            username with your Gmail ID and password with your Gmail Password.

4.  Create a Postfix lookup table from the sasl_passwd text file by running the
    following command:

    $ sudo postmap /etc/postfix/sasl_passwd

    Note:   smtp_tls_CAfile

            The Postfix configuration parameter smtp_tls_CAfile may exist in
            several places in the /etc/postfix/main.cf file. This parameter
            specifies the full pathname of a file containing CA certificates of
            root CA's trusted to sign either remote SMTP server certificates or
            intermediate CA certificates. This is needed if you want it to be
            able to use TLS when sending mail to other servers.

            The following warning message will be displayed if duplicate entries
            are found in /etc/postfix/main.cf:

                postmap: warning: /etc/postfix/main.cf, line 745: overriding
                earlier entry: smtp_tls_CAfile=/etc/pki/tls/certs/ca-bundle.crt

            It's often the case this parameter will be set to the files
            /etc/pki/tls/certs/ca-bundle.crt or /etc/ssl/certs/ca-bundle.crt.
            These files are the same.

            Comment out one of the entries for smtp_tls_CAfile.

Send Test Email:

    $ echo "This is test mail." | mail -s "message" dba@acmeindustries.com

    or

    $ echo -e "To: dba@acmeindustries.com\nSubject: Email Test\nThis is a testing email from the local domain\n" | /usr/lib/sendmail -bm -t -v

    or

    $ /usr/lib/sendmail -v dba@acmeindustries.com < ~/.profile
