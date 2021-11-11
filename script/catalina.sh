# setup script for macOS Catalina, pre nix-install
# NOTE that regular nix setup does essentially the same, this is here for reference

set -e


PIN=''
get_pin()
{
	while [ -z "$PIN" ]; do
		echo -n 'Disk Encryption Key:'
		read -r -s PIN
		echo
		echo -en 'repeat key:'
		read -r -s CHECK
		echo
		if [ "$PIN" != "$CHECK" ]; then
			PIN=''
			echo 'passwords did not match; retry'
		fi
	done
}


# toplevel mount dir
if ! [ -d /nix ]; then
	echo 'nix' | sudo tee -a /etc/synthetic.conf
	sudo reboot
fi

# APFS volume
# TODO: _assumes_ the install disk 'disk1' - must be sanity-checked
if ! diskutil list | grep -q Nix; then
	get_pin
	sudo diskutil apfs addVolume disk1 APFSX Nix -mountpoint /nix -passphrase "$PIN"
fi

sudo diskutil enableOwnership /nix
sudo chmod 755 /nix
sudo chflags hidden /nix
sudo chown -R "$(whoami)" /nix 2>/dev/null

echo 'You can now install Nix normally by running:'
echo
echo 'curl https://nixos.org/nix/install | sh'
