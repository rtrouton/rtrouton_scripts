#!/bin/sh

# Add syslog server(s) to /etc/syslog.conf

/bin/echo "*.* @syslogserver1.domain.com" >> /etc/syslog.conf 
/bin/echo "*.* @syslogserver2.domain.com" >> /etc/syslog.conf

# Force the syslog process to reread /etc/syslog.conf

/usr/bin/killall -HUP syslogd