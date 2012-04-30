#!/bin/bash
#
# GPLv2
# GPG Encrypt a Maildir using gpgencmail.pl, removing any S= or W= virtual flags.
# Sep 02, 2011
#
# Change log:
#     Sep 03, 2011
#               - Temporary file is based on file_owner to avoid issues with permission differences.
#               - Temporary file is removed after run.
#               - Optional arguments passed to 'find'.
#               - Full paths to binaries.
#               - Removed unneccessary need of 'cat', 'grep', etc.
#     Sep 04, 2011
#               - Don't remove Dovecot index/uid unless messages have been GPG encrypted.
#               - Adjust file tests to not just use -e
#               - Quote all file operations
#     Sep 05, 2011
#               - Don't arbitrarily copy files, only overwrite the file in ~/Maildir if it differs after calling gpgencmail.pl
#               - Only rebuild the index if we have modified ~/Maildir

# source : http://www.dslreports.com/forum/remark,26270484 (retrieved throug google's cache), slightly modified by olivier.berger@it-sudparis.eu

#ENCRYPTER=/usr/local/bin/gpgencmail.pl
ENCRYPTER=~/bin/gpgit.pl
  
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  /bin/echo "Usage is ./encmaildir.sh /path/to/Maildir certificate_user@domain.com file_owner {optional arguments passed to 'find' for messages such as '-mtime 0'}"
  exit 0
fi
  
if [ ! -d "$1" ]; then
        /bin/echo "The directory of '$1' does not exist!"
        exit 0
fi
  
#Does this key exist?
/usr/bin/gpg --list-keys "$2" > /dev/null 2>&1
if [ $? -gt 0 ]; then
     /bin/echo "A GPG key for '$2' could not be found!"
     exit 0
fi
  
#Find all files in the Maildir specified.
/bin/echo "Calling /usr/bin/find \"$1\" -type f -regex '.*/\(cur\|new\)/.*' $4"

/usr/bin/find "$1" -type f -regex '.*/\(cur\|new\)/.*' $4 | while read line; do

#    echo "cat $line | $ENCRYPTER --encrypt-mode prefer-inline $2 > /tmp/msg_$3"
#    echo "Processing : $(grep '^Subject:'  $line)"
     cat "$line" | $ENCRYPTER --encrypt-mode prefer-inline "$2" > "/tmp/msg_$3"
  
     #Check to see if there are differences between the existing Maildir file and what was created by gpgencmail.pl
     /usr/bin/diff -qa "$line" "/tmp/msg_$3" > /dev/null 2>&1;
     if [ $? -gt 0 ]; then
          #Preserve timestamps, set ownership.
          /bin/chown $3:$3 "/tmp/msg_$3"
          /bin/chmod 600   "/tmp/msg_$3"
          /usr/bin/touch   "/tmp/msg_$3" --reference="$line"
  
          #Unlink the original Maildir message
#	  echo " /usr/bin/unlink $line"
          /usr/bin/unlink "$line"
  
          #Strip message sizes, retain experimental flags and status flags, and copy the file over.
          STRIPSIZES=$(/bin/echo "$line"|/bin/sed -e 's/W=[[:digit:]]*//' -e 's/S=[[:digit:]]*//' -e 's/,,//' -e 's/,:2/:2/')
#	  echo "/bin/cp -av /tmp/msg_$3 $STRIPSIZES"
          /bin/cp -av "/tmp/msg_$3" "$STRIPSIZES"
  
          #Indexes must be rebuilt, we've modified Maildir.
          /usr/bin/touch "/tmp/rebuild_index_$3"
     else
          /bin/echo "Not copying, no differences between '/tmp/msg_$3' and '$line'"
     fi
  
        #Remove the temporary file
        /usr/bin/unlink "/tmp/msg_$3"
done
  
#Remove Dovecot index and uids for regeneration.
if [ -f "/tmp/rebuild_index_$3" ]; then
        /bin/echo "Removing Dovecot indexes and uids"
        /usr/bin/find "$1" -type f -regex '.*\(dovecot-\|dovecot\.\|\.uidvalidity\).*' -delete
  
        #Remove the temporary file
        /usr/bin/unlink "/tmp/rebuild_index_$3"
else
        /bin/echo "No messages found needing GPG encryption, not removing Dovecot indexes and UIDs."
fi
