#	mac_tftp.sh
# Start and then stop a tftp server on a macOS machine
#
# Why does this require a script, you ask?
# Because 'tftpd' is set up so that it WILL NOT run on the command line, but instead:
# - requires a specific .plist path to load and unload
# - but DOESN'T give status when referencing the .plist
#	... for that we need to use com.apple.tftpd
#
# Can we make it ANY MORE COMPLICATED to just run a tftpd in a directory
# and drop a file somewhere? It's supposed to be called TRIVIAL people!
#
# (c) 2020 Sirio Balmelli

PLIST=/System/Library/LaunchDaemons/tftp.plist

sudo launchctl load -F $PLIST
#sudo launchctl list com.apple.tftpd

# Read the server directory from arguments in the .plist;
# this is usually '/private/tftpboot'.
SRVDIR=$(xmllint --xpath "string(//dict/array/string[3])" $PLIST)
sudo chmod -R ugo+rwX $SRVDIR

echo "serving on '$SRVDIR'"
echo press any key to kill
read KEY
sudo launchctl unload -F $PLIST
