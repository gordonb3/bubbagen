#!/bin/sh
# Copyright (c) 2016 gordonb3 <gordon@bosvangennip.nl>
# License: GPL 3.0+
# NO WARRANTY
#
# Installs the default config files for Bubbagen OS.
# Adapt to your requirements.
# WARNING - will overwrite the config for all packages controlled by the Bubba web admin interface
# (including networking)

echo "Install the default config files for Bubbagen OS."
echo
if ! $(echo $* | grep -q FORCEINSTALL); then
echo "WARNING - will overwrite the config for all packages controlled"
echo "by the Bubba web admin interface"
echo "Please make sure you have adequate backups before proceeding"
echo
echo "Type (upper case) INSTALL and press Enter to continue"
read -p "Any other entry quits without installing: " REPLY
if [[ ! "${REPLY}" == "INSTALL" ]]
then
    echo "You did not type INSTALL - exiting" >&2
    exit 1
fi
fi

if [ ! -e /var/lib/bubba/bubba-default-config.tgz ]; then
	echo "ERROR: bubba-default-config not found. Please reinstall the bubba package" >&2
	exit 1
fi

# Unpack Bubba default config
echo "Unpack source"
cd /tmp
tar -xzf /var/lib/bubba/bubba-default-config.tgz

if $(echo $* | grep -q minimal); then
	ls -1 etc | while read fentry; do
		if [ ! -e /etc/${fentry} ] && [ -e etc/${fentry} ]; then
			pkg=$(echo ${fentry} | awk -F. '{print $1}')
			echo "Clean config for non installed package ${pkg}"
			if [ "${pkg}" == "${fentry}" ]; then
				rm -r etc/${pkg}
			else
				rm -r etc/${pkg}.*
			fi
		fi
	done
else
	# Always clean these packages
	for pkg in "apache2" "nginx" "tor"; do
		if [ ! -e /etc/${pkg} ]; then
			echo "Clean config for non installed package ${pkg}"
			rm -r etc/${pkg}
		fi
	done
fi

# Maintain owners and rights of existing files
find etc | while read fentry; do
	if [ -e "/${fentry}" ]; then
		chown --reference=/${fentry} ${fentry}
		chmod --reference=/${fentry} ${fentry}
	fi
done

# Make a backup of the existing config files
if ! $(echo $* | grep -q nobackup); then
	if [ -e /home/admin/gentoo-settings-backup.tgz ] ; then
		echo "WARNING: cowardly refusing to overwrite existing config backup file"
	else
		mkdir -p backup/etc
		find etc -type d -exec mkdir -p backup/{} \;
		find etc -type f -exec cp -a /{} backup/{} 2>/dev/null \;
		tar -C backup -czf /home/admin/gentoo-settings-backup.tgz etc
		chown admin /home/admin/gentoo-settings-backup.tgz
		rm -r backup
		echo "A backup of your original settings has been saved in /home/admin/gentoo-settings-backup.tgz"
	fi
fi

# Install configs
echo "Installing config files"
cp -a etc /
rm -r etc
cd - >/dev/null

# Create admin user if not exist (prefer uid=1000, gid=1000)
if [ -z "$(getent passwd admin)" ]; then
	echo "Creating admin user"
	if [ ! -z "$(getent passwd 1000)" ]; then
		echo "WARNING: preferred admin uid 1000 is already assigned. You may not be able to see and manage all your users through Bubba web admin interface."
		do_uid=""
	else
		do_uid="-u 1000"
	fi
	if [ -z "$(getent group admin)" ]; then
		if [ -z "$(getent group 1000)" ]; then
			groupadd -g 1000 admin
		else
			groupadd admin
		fi
	fi
	useradd -c "Administrator" -d /home/admin -g admin -G users,lpadmin ${do_uid} -m -s /bin/false admin
	rmdir /home/admin/{downloads,torrents,private} 2>/dev/null
fi

# Reset admin password
echo -e "admin\nadmin" | passwd -q admin 2>/dev/null
echo -e "admin\nadmin" | smbpasswd -as admin
echo "Admin user password has been set to 'admin'"


# Should we run wizard on first access to the web admin interface?
if $(echo $* | grep -q nowizard); then
	if [ ! -e /home/admin/.bubbacfg ]; then
		echo 'Enabling default network profile "Router + Firewall + Server"'
		cat > /home/admin/.bubbacfg << EOF
default_lang=en
default_locale=en_US
network_profile=router
run_wizard=no
EOF

	else
		echo "" >> /home/admin/.bubbacfg
		sed -i -e "/run_wizard/d" -e "/^\s*$/d" /home/admin/.bubbacfg
		echo "run_wizard=no" >> /home/admin/.bubbacfg
	fi
fi

if [ ! -e /home/admin/.bubbacfg ]; then
	echo "run_wizard=yes" > /home/admin/.bubbacfg
fi
chown admin /home/admin/.bubbacfg


# Set networking
echo "Setting network defaults"
if $(ip link show wlan0 2>/dev/null | grep -q "state"); then
	if $(ip link show wlan0 2>/dev/null | grep -q "state UP"); then
		echo "WARNING: you currently have WiFi enabled, the new system will start without it"
	fi
	systemctl is-enabled hostapd &>/dev/null && systemctl disable hostapd
fi
if $(systemctl is-active NetworkManager); then
	conn=$(nmcli d | grep "^eth0\s")
	if [ conn != "WAN" ]; then
		if [ conn != "--" ]; then
			nmcli connection delete ${conn}
		fi
		nmcli connection add type ethernet con-name WAN ifname eth0
	fi
	conn=$(nmcli d | grep "^eth1\s")
	if [ conn != "LAN" ]; then
		if [ conn != "--" ]; then
			nmcli connection delete ${conn}
		fi
		nmcli connection add type ethernet con-name LAN ifname eth1
	fi
fi


# Services config
echo "Enable basic services"
delsrvcs="bootled iptables shorewall dhcpcd"
addsrvcs="apache2 bubba-adminphp bubba-buttond bubba-firewall dnsmasq haveged ntpd samba sshd NetworkManager NetworkManager-dispatcher"

for srvc in ${delsrvcs}; do
	systemctl is-enabled ${srvc} &>/dev/null && systemctl disable ${srvc}
done

for srvc in ${addsrvcs}; do
	systemctl is-enabled ${srvc} &>/dev/null || systemctl enable ${srvc}
done


echo ""
echo 'All done! Please reboot to activate the new settings.'
echo "Then visit http://$(hostname)/admin to get started with Bubbagen."

