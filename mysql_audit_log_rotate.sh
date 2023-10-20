#!/bin/bash
# Bash script to backup MySQL database - Physical backup
# Author: Anban Malarvendan
# License: GNU GENERAL PUBLIC LICENSE Version 3 + 
#          Section 7: Redistribution/Reuse of this code is permitted under the 
#          GNU v3 license, as an additional term ALL code must carry the 
#          original Author(s) credit in comment form.
 
logDirectory="/var/log"
rotationDirectory="/home/your_username/audit_log_rotation"
backupDirectory="/BACKUP/database/audit_logs"
serverName="your_server_name"
serverIP="your_server_ip"
recipientEmail="your_email@gmail.com"
attachmentPath="/home/your_username/audit_log_rotation/audit_alert.log.gz"
 
# Search for specific keywords in the MySQL audit log
egrep -i 'alter table|update table|delete table' $logDirectory/mysql_audit.log | sort -u > $rotationDirectory/mysql_audit.txt
 
# Compress the MySQL audit log and save it as audit_alert.log.gz
sudo cat $logDirectory/mysql_audit.log | gzip > $rotationDirectory/audit_alert.log.gz
 
# Create an archive of the audit log with a timestamp in the filename
sudo cat $logDirectory/mysql_audit.log | gzip > $backupDirectory/audit_archived_`date +%Y-%m-%d-%H:%M:%S`.log.gz
 
# Check if log compression and archiving were successful
if [ $? -eq 0 ]; then
    # Empty the original MySQL audit log
    sudo cat /dev/null > $logDirectory/mysql_audit.log
else
    echo "Failed to empty the file"
fi
 
# Check if the sorted audit log file is not empty
if [ -s "$rotationDirectory/mysql_audit.txt" ]; then
    # Send an email with the sorted audit log as an attachment
    cat $rotationDirectory/mysql_audit.txt | mutt -s "Daily Audit Log for MySQL database on $serverName ($serverIP) at `date`" ${recipientEmail} -a ${attachmentPath}
fi
 
# Check if the email sending process was successful
if [ $? -eq 0 ]; then
    # Clean up log files in the specified directory
    cd /tmp/
    cd $rotationDirectory
    rm -f *.log.gz
    rm -f *.txt
else
    echo "Failed to send the logs via email"
fi
