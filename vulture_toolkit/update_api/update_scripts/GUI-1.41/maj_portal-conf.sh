#!/bin/sh
#
# This migration script add the 'WSGIApplicationGroup %{GLOBAL}' directive
#  in the /home/vlt-sys/Engine/conf/portal-httpd.conf by replacing all the file
#

if [ "$(cat /home/vlt-sys/Engine/conf/portal-httpd.conf | grep 'WSGIApplicationGroup %{GLOBAL}')" != "" ]
then
    /bin/echo "It seems that this script has already been executed. Quitting."
else
    /bin/echo 'ServerRoot "/home/vlt-sys/Engine"
PidFile /home/vlt-sys/run/portal.pid
ScoreBoardFile /home/vlt-sys/run/portal.scoreboard
WSGISocketPrefix /home/vlt-sys/run/
WSGIPassAuthorization On
Mutex sem

Listen 127.0.0.1:9000 http

#Autorisation helper (require valid-use / hostr)
LoadModule authz_core_module modules/mod_authz_core.so

#Bandwith, timeout and performance helpers
LoadModule reqtimeout_module modules/mod_reqtimeout.so

#Core helpers
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so
LoadModule wsgi_module modules/mod_wsgi.so
LoadModule headers_module modules/mod_headers.so

#Rewrite helpers
LoadModule rewrite_module modules/mod_rewrite.so

#Deflate helper
#LoadModule deflate_module modules/mod_deflate.so

User vlt-portal
Group vlt-portal

ServerAdmin root@localhost

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "/var/log/Vulture/portal/Apache-error.log"
LogLevel error

LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%a %l %u %t \"%r\" %>s %b" common

TypesConfig conf/mime.types

ErrorDocument 403 /templates/static/html/error-403.html
ErrorDocument 404 /templates/static/html/error-404.html
ErrorDocument 500 /templates/static/html/error-500.html

AcceptFilter http httpready
AcceptFilter http dataready

EnableMMAP on
EnableSendfile on
ExtendedStatus on

ServerLimit		16
ThreadsPerChild         25
MinSpareThreads         75
MaxSpareThreads        250
MaxRequestWorkers      400
MaxConnectionsPerChild   0

Timeout 15
KeepAlive On
KeepAliveTimeout 5
MaxKeepAliveRequests 100
UseCanonicalName Off
AccessFileName .htaccess
ServerTokens Prod
ServerSignature Off
HostnameLookups Off
RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500

<VirtualHost 127.0.0.1:9000>
    ServerName 127.0.0.1
    DocumentRoot "/home/vlt-gui/vulture"

    CustomLog "/var/log/Vulture/portal/Apache-access.log" combined

    WSGIScriptAlias / /home/vlt-gui/vulture/portal/wsgi.py
    WSGIDaemonProcess portal python-path=/home/vlt-gui/vulture:/home/vlt-gui/env/lib/python2.7/site-packages
    WSGIProcessGroup portal
    WSGIApplicationGroup %{GLOBAL}


    #No cache at all for portal
    Header always set Cache-Control "no-cache, no-store, must-revalidate"
    Header always set Pragma "no-cache"
    Header always set Expires "0"

    Alias /templates/static/ /home/vlt-gui/vulture/portal/static/
    <Directory /home/vlt-gui/vulture/portal/static>
       Require all granted
    </Directory>
    Alias /templates/ /home/vlt-gui/vulture/portal/templates/
    <Directory /home/vlt-gui/vulture/portal/templates>
       Require all granted
    </Directory>

    <Directory /home/vlt-gui/vulture>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    #Whitelist of allowed URI
    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/templates/static/.*$ [NC]
    RewriteCond %{REQUEST_URI} !^/portal/.*/.*$ [NC]
    RewriteCond %{REQUEST_URI} !^/portal/learning$ [NC]
    RewriteCond %{REQUEST_URI} !^/portal/2fa/otp$ [NC]
    RewriteCond %{REQUEST_URI} !^/portal/.*/portal_statics/.*$ [NC]
    RewriteCond %{REQUEST_URI} !^/templates/portal_.*_css\.conf$ [NC]
    RewriteCond %{REQUEST_URI} !^/templates/portal_.*\.png$ [NC]
    RewriteCond %{REQUEST_URI} !^/templates/portal_.*_html_error_[0-9]{3}\.html$ [NC]
    RewriteRule .* - [F,NC]

</VirtualHost>
' > /home/vlt-sys/Engine/conf/portal-httpd.conf

    /usr/bin/chown vlt-sys:vlt-conf /home/vlt-sys/Engine/conf/portal-httpd.conf
    /bin/chmod     644              /home/vlt-sys/Engine/conf/portal-httpd.conf

fi
