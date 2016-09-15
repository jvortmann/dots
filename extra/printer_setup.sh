# Copyright PaperCut Software, 2007
#
# Author: Chris Dance (chris.dance <a> papercut.com)
# A simple  to copy printer configuration from one Apple Mac OS X
# system to another.
#

TARGET_HOST=`hostname`
SRC_HOST=$1
SRC_USER=root

if [ -z "${SRC_HOST}" ]; then
    echo
    echo "USAGE: pull-printer-config SOURCE [USER]"
    echo "    SOURCE: The remote system whose printer config you'd like to copy."
    echo "    USER: An admin level user on the source system. If not defined root is used."
    echo
    exit 1
fi

if [ ! -z "$2" ]; then
    SRC_USER=$2
fi

userid=`id | sed "s/^uid=\([0-9][0-9]*\).*$/\1/"`
if test "${userid}" -ne 0; then
    echo "Error: Please run this  as root (e.g. sudo pull-printer-config)" 1>&2
    exit 1
fi


echo "Copying printer configuration from ${SRC_HOST} to ${TARGET_HOST}."
echo "Enter the password for the user ${SRC_USER} on ${SRC_HOST} if requested."
echo "You may be requested for your password multiple times."
echo

#
# On the target system take a copy of our cups config and set ourselves as the
# owner.
#
echo "Preparing config on source server..."
ssh -t "${SRC_USER}@${SRC_HOST}" \
    "sudo sh -c \
    \"rm -fr /tmp/cupstmp; cp -R /etc/cups/ /tmp/cupstmp; chown -R ${SRC_USER} /tmp/cupstmp\""

if [ "$?" -ne "0" ]; then
    echo "Error: Unable to source config of remote system" 1>&2
    exit 1
fi

#
# Use scp to copy our temp copy over to our local system.
#
echo "Copying config..."

rm -fr /etc/cupstmp >/dev/null 2>&1

#
# Move old config
#
scp -rpq "${SRC_USER}@${SRC_HOST}:/tmp/cupstmp/" "/etc/cupstmp"
if [ ! -d /etc/cupstmp  ]; then
    #
    # Error so restore our backup
    #
    echo "Error: Unable to copy files." 1>&2
    exit 1
fi

datestamp=`date +%y%m%d`
mv /etc/cups "/etc/cups${datestamp}" && mv /etc/cupstmp /etc/cups

#
# Restart the CUPS server so it picks up our new config.
#
killall -HUP cupsd

echo "Copy complete."
