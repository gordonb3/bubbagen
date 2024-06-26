# bubbagen

Bootable live-USB of Bubba OS for the Excito B3 miniserver, build on Gentoo (kernel 6.6.13 - Gentoo stable)

## Description

<img src="https://raw.githubusercontent.com/gordonb3/cache/master/Bubba/Excito-B3.jpg" alt="Excito B3" width="250px" align="right"/>
This project is a spin-off from [Sakaki's gentoo-on-b3 project](https://github.com/sakaki-/gentoo-on-b3) and contains what was previously published as the `Special Edition` while the Bubba overlay was still in beta.<br><br>
  
As with the original, this project contains a bootable, live-USB image for the Excito B3 miniserver. You can use it as a rescue disk, to play with Gentoo Linux, or as the starting point to install Gentoo Linux on your B3's main hard drive. You can even use it on a diskless B3. No soldering, compilation, or [U-Boot](https://www.denx.de/project/u-boot/) flashing is required! You can run it without harming your B3's existing software; however, any changes you make while running the system *will* be saved to the USB (i.e., there is persistence).

The kernel used in the image is **6.6.13** from gentoo-sources, with the necessary code to temporarily switch off the L2 cache in early boot (per [this link](https://lists.debian.org/debian-boot/2012/08/msg00804.html)) prepended, and the kirkwood-b3 device tree blob appended.

The image may be downloaded from the link below and should work, without modification, whether your B3 has an internal hard drive fitted or not.

Variant | Init type | Version | Image
:--- | ---: | ---: | ---:
B3 with or without Internal Drive | openRC | 1.18.0 | [bubbagenb3img-1.18.0.xz](https://github.com/gordonb3/bubbagen/releases/download/v1.18/bubbagenb3img-1.18.0.xz)

> Please read the instructions below before proceeding. Also please note that all images are provided 'as is' and without warranty.

## Prerequisites

To try this out, you will need:
* A USB key of at least 8GB capacity (the *uncompressed* image is 14,813,184 (512 byte) sectors = 7,584,350,208 bytes). Unfortunately, not all USB keys work with the various versions of [U-Boot](https://www.denx.de/project/u-boot/) that were factory installed on the B3. Most SanDisk and Lexar USB keys appear to work reliably, but others (e.g., Verbatim keys) will not boot properly. (You may find the list of known-good USB keys [in this post](https://forum.doozan.com/read.php?2,1915,page=1) useful.)
* An Excito B3 (obviously!).
* A PC to decompress the image and write it to the USB key (of course, you can also use your B3 for this, assuming it is currently running the standard Excito / Debian Squeeze system). This is most easily done on a Linux machine of some sort, but tools are also available for Windows (see [here](https://tukaani.org/xz/) and [here](https://sourceforge.net/projects/win32diskimager/), for example). In the instructions below I'm going to assume you're using Linux.


## Downloading and Writing the Image

On your Linux box, issue:
```
# wget -c https://github.com/gordonb3/bubbagen/releases/download/v1.18/bubbagenb3img-1.18.0.xz
```
to fetch the compressed disk image file

Next, insert (into your Linux box) the USB key on which you want to install the image, and determine its device path (this will be something like `/dev/sdb`, `/dev/sdc` etc.; the actual path will depend on your system, you can use the `lsblk` tool to help you). Unmount any existing partitions of the USB key that may have automounted (using `umount`). Then issue:

> **Warning** - this will *destroy* all existing data on the target drive, so please double-check that you have the path correct!

```
# xzcat bubbagenb3img-1.18.0.xz > /dev/sdX && sync
```

Substitute the actual USB key device path, for example `/dev/sdc`, for `/dev/sdX` in the above command. Make sure to reference the device, **not** a partition within it (so e.g., `/dev/sdc` and not `/dev/sdc1`; `/dev/sdd` and not `/dev/sdd1` etc.)

The above `xzcat` to the USB key will take some time, due to the decompression (it takes between 8 and 20 minutes on my machine, depending on the USB key used). It should exit cleanly when done - if you get a message saying 'No space left on device', then your USB key is too small for the image, and you should try again with a larger capacity one.


## Booting!

Begin with your B3 powered off and the power cable removed. Insert the USB key into either of the USB slots on the back of the B3, and make sure the other USB slot is unoccupied. Connect your B3 into your local network (or directly to your ADSL router, cable modem etc., if you wish) using the **wan** Ethernet port. Then, *while holding down the button on the back of the B3*, apply power (insert the power cable). After two seconds or so, release the button. If all is well, the B3 should boot the kernel off of the USB key (rather than the internal drive), and then proceed to mount the root partition (also from the USB key) and start Gentoo. This will all take about 40 seconds or so. The LED on the front of the B3 should:

1. first, turn **green**, for about 30 seconds, as the bootloader is starting; then,
1. turn **off** for about 5 seconds as the real kernel is loading, then 
1. turn **purple** for about one and a half minute while the system is initializing; and finally,
1. turn **green** again when the system is fully functional.

> The `purple` state will use 15 seconds less if you attach the WAN port to a valid existing network

> The image uses a solid green LED as its 'normal' state to show that your B3 is running from USB key. This should make it easy to identify whether your system booted from USB or hard drive (stock Sakaki gentoo-on-b3 will also show green LED when running from harddrive)

After the LED turns green in step 3, above, you should be able to log in, via `ssh`, per the following instructions.

## Connecting to the B3

First, connect your client PC (or Mac etc.) to the **lan** Ethernet port of your B3 (you can use a regular Ethernet cable for this, the B3's ports are autosensing). WiFi is disabled. Once booted, you can use your browser to connect to the B3 through [http://b3](http://b3), where you should see the familiar Excito B3 admin. The default username and password for the administrator account is:
**&nbsp; &nbsp; Username: admin**
**&nbsp; &nbsp; Password: admin**

As a security measure, it is strongly recommended to change the admin password. Please reference the Excito manual ([online version on your booted B3](http://b3/manual))

Alternatively you may log into the B3 using an ssh client:

```
$ ssh root@b3
The authenticity of host 'b3 (192.168.10.1)' can't be established.
ED25519 key fingerprint is 0c:b5:1c:66:19:8a:dc:81:0e:dc:1c:f5:25:57:7e:66.
Are you sure you want to continue connecting (yes/no)? <type yes and press Enter>
Warning: Permanently added 'b3,192.168.10.1' (ED25519) to the list of known hosts.
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
and you're in! You may receive a different fingerprint type, depending on what your `ssh` client supports. Also, please note that the `ssh` host keys are generated on first boot (for security), and so the fingerprint you get will be different from that shown above.

> If you have trouble with `ssh root@b3`, you can also try using `ssh root@192.168.10.1` instead.

If you have previously connected to a *different* machine with the *same* IP address as your B3 via `ssh` from the client PC, you may need to delete its host fingerprint (from `~/.ssh/known_hosts` on the PC) before `ssh` will allow you to connect.

> Incidentally, you should also be able to browse the web etc. from your client (assuming that you connected the B3's `wan` port prior to boot), because the image has a forwarding firewall setup.

## Using Gentoo

For the main text on this, please refer to the [older README](https://github.com/gordonb3/bubbagen/blob/v1.18/reference/gentoo-on-b3-1.8.0-README.md) by Sakaki.


The following major changes to the original 1.8.0 release from Sakaki apply:

1. The image supplied kernel is version 6.6.13 and supports both openrc and systemd init systems. 

1. The live USB image has been brought up to date against the Gentoo tree as of 21 Apr 2024. The full set of packages in the image may be viewed [here](https://github.com/gordonb3/bubbagen/blob/v1.18/reference/installed-packages-1.18.0).

1. The bubbagen image has sysvinit patched to follow the hardware specific routine for shutting down. As such you can now simply use `halt` or `poweroff` commands (Sakaki's `poweroff-b3` script is not available in this image) to shut down the B3.
> Please note that the B3 does not actually power down but enters a special pre boot environment where it waits for the button on the rear to be pressed. As multiple users discovered, this happens to be pretty CPU intensive and the B3 may run quite hot and even use more power than when running an OS.

Have fun! ^-^

## Changes since version 1.17
* switched to Gentoo profile 23

## Changes since version 1.16
* dropped systemd as a binary release - see [wiki](https://github.com/gordonb3/bubbagen/wiki) if you like to switch to systemd
* switched to merged-usr root filesystem
* fixed DHCP server not coming up when the B3 falls back to its predifined address 192.168.10.1
* added a time correcting service for machines with a dead RTC battery which caused the GUI to be unreachable
* fixed various PHP deprecation notices in the GUI
* added Web Service Discovery daemon that allows your B3 to be listed in Windows Network
* Logitech Media Server will now start with mysqueezebox.com integration disabled - service will end first quarter of 2024
* removed the gentoo-b3 repository
  * the only remaining package was sys-kernel/buildkernel-b3 which failed with kernel 6.6
  * revised package sys-kernel/buildkernel-b3 is now part of the bubba repository

## Changes since version 1.15
* kernel: smaller core due to full revision of config, removing obsolete
* developer language updates: gcc 13.2, perl 5.38
* fixed an issue with bubba-admin ebuild going into deadlock during post-install
* updated Logitech Media Server to the latest stable version 8.3.1
* re-added Tor anonymous communication router to @bubba set
* removed Easyfind client - service was terminated in June 2023

## Older changes

* kernel:
 * added support for latest gen Intel wifi adapters
 * added wireguard VPN support
 * bubbagen kernel is now a binary package
 * bootloader revision
* package management:
 * switch to user patches to handle platform specific changes to ebuilds more reliably
 * consolidated the bubba admin packages to a single package
 * fixed the old sakaki repos to conform to minimal EAPI requirements
 * due to Sakaki's retirement the following repositories have been cleaned and marked user_defined:
  * gentoo-b3: deleted all except sys-kernel/buildkernel-b3
  * sakaki-tools: deleted all except app-portage/genup and app-portage/showem
 * removed obsolete php cgi
 * package related settings specific to this distribution are now owned by bubbagen package
 * bindist USE flag pre-removed from global make profile
* features:
 * disabled torrent support in net-p2p/filetransferdaemon
 * now using nftables as the firewall back-end
* GUI updates:
 * removed build dependency on resources unfriendly ruby, nodejs and spidermonkey
 * empty postdata on lanupdate would cause the NIC to be set to dynamic IP
 * fix display of AllowRemote value for admin user
 * block enabling the WiFi AP when LAN is set to receive its IP through DHCP (causes network to fail)

## Miscellaneous Points

* The image is subscribed to the following overlays:
  * [`bubba`](https://github.com/gordonb3/bubba-overlay): this overlay provides the `Bubba OS` and `Logitech Media Server`. It also provides ebuilds for the home automation software Domoticz and supporting software; these have not been installed in the image, but you can easily `emerge` them if you like.
* The following unmaintained overlays from Sakaki have been converted to user-defined repositories and stripped down to provide the following named packages:
  * [`sakaki-tools`](https://github.com/sakaki-/sakaki-tools): this overlay (provided by Sakaki) provides the tools `showem` ([source](https://github.com/sakaki-/showem), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/showem.pdf)) and `genup` ([source](https://github.com/sakaki-/genup), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup.pdf)). (Note - these replace the old `showem-lite` and `genup-lite` tools.)
  * [`gentoo-b3`](https://github.com/sakaki-/gentoo-b3-overlay): this overlay (provided by Sakaki) provides the `buildkernel-b3` tool ([source](https://github.com/sakaki-/buildkernel-b3), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)).
* Please note that the firewall, as initially configured, will allow `ssh` traffic on the `wan` port also.
* Apart from Apache web server to run the Bubba User Interface, Samba file sharing is also enabled by default
* There is no MySQL in the bubbagen image. Reason? It consumes too much memory (YMMV). Original Excito Bubba OS Services that used it have either been adapted to use SQLite instead, or been replaced by alternatives. Webmail is now served by Roundcube and bubba-album was dropped in favor of Singapore Gallery (sgal).
* If you have a WiFi-enabled B3, the corresponding network interface is named `wlan0` (there is a `udev` rule that does this, namely `/lib/udev/rules.d/70-net-name-use-custom.rules`). Do note that this rule will **not** work correctly if you have more than one WiFi adaptor on your B3 (an unusual setup) or replaced the WiFi adapter with a different brand.
* The image includes a 1GiB swap partition, and also has sufficient space in its root partition to e.g., perform a kernel compilation, should you so desire.
* If you have a USB key larger than the minimum 8GB, after writing the image you can easily extend the size of the second partition (using `fdisk` and `resize2fs`), so you have more space to work in. See [these instructions](https://geekpeek.net/resize-filesystem-fdisk-resize2fs/), for example.
* Postfix has been reconfigured to disallow starttls on the regular port 25. Use submission or ssmtp ports instead if you want to use relay from other than the lan interface.
* Emails to root (e.g. failed cron jobs) are forwarded to `admin`. Enable `Send and receive` and `IMAP` in the services tab to read them.

## <a name="hdd_install">Installing Bubbagen on your B3's Internal Drive (Optional)

If you like Bubbagen, and want to set it up permanently on the B3's internal hard drive, you can do so easily. The full process is described below. (Note, this is strictly optional, you can simply run Bubbagen from the USB key, if you are just experimenting, or using it as a rescue system.)

> **Warning** - the below process will wipe all existing software and data from your internal drive, so be sure to back that up first, before proceeding. It will set up:
* /dev/sda1 as a 64MiB boot partition, and format it `ext3`;
* /dev/sda2 as a 1GiB swap partition;
* /dev/sda3 as a 20GiB root partition, and format it `ext4`.
* /dev/sda4 as a home partition using the rest of the drive, and format it `ext4`.

> If you like the root partition to be bigger you can specify this in `/root/install.ini`

> The script [`/root/install_on_sda.sh`](file:///) will automatically decide between creating a new DOS or GPT partition table; if you want to force selection (disks <=2TiB only; larger disks will always be GPT), then use fdisk to create the right type partition table prior to running the install script. 

OK, first, boot into the image and then connect to your B3 via `ssh`, as described above. Then simply run the supplied script to install onto your hard drive:
```
b3 ~ # /root/install_on_sda.sh
Install Gentoo -> /dev/sda (B3's internal HDD)

WARNING - will delete anything currently on HDD
(including any existing Excito Debian system)
Please make sure you have adequate backups before proceeding

Type (upper case) INSTALL and press Enter to continue
Any other entry quits without installing: <type INSTALL and press Enter, to proceed>
Installing: check '/var/log/gentoo_install.log' in case of errors
Step 1 of 5: creating new "dos" partition table on /dev/sda...
Step 2 of 5: formatting partitions on /dev/sda...
Step 3 of 5: mounting boot and root partitions from /dev/sda...
Step 4 of 5: copying system and bootfiles (please be patient)...
Step 5 of 5: syncing filesystems and unmounting...
All done! You can reboot into your new system now.
```

That's it! You can now try rebooting your new system (it will have the same initial network settings as the USB version, since we've just copied them over). Issue:
```
b3 ~ # reboot
```
And let the system shut down and come back up. **Don't** press the B3's back-panel button this time. The system should boot directly off the hard drive. You can now remove the USB key, if you like, as it's no longer needed. Wait for the front LED on the B3 to turn `blue`, then from your PC on the same subnet issue:
```
> ssh root@b3
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
Of course, if you changed root's password in the USB image, use that new password rather than `gentoob3` in the above.

Once logged in, feel free to configure your system as you like! Of course, if you're intending to use the B3 as an externally visible server, you should take the usual precautions, such as changing `root`'s password, configuring the firewall, possibly [changing the `ssh` host keys](https://missingm.co/2013/07/identical-droplets-in-the-digitalocean-regenerate-your-ubuntu-ssh-host-keys-now/#how-to-generate-new-host-keys-on-an-existing-server), etc.


### Keeping Your Gentoo System Up-To-Date

Please refer to the corresponding section(s) in the [older README](https://github.com/gordonb3/bubbagen/blob/v1.18/reference/gentoo-on-b3-1.8.0-README.md) by Sakaki.


### Upgrading from a previous version of Bubbagen

**Warning** This will still clear your complete system and you will lose any additional packages you installed.

* make a backup of your /etc and /var/lib directories
* run the installer - make a note that it says it will keep /home before proceeding
* restore /var/lib
* restore /etc but keep the following files from the image:
  * /etc/bubba/bubba.version
  * /etc/portage/*
  * /etc/dovecot/*
  * /etc/php/*
  * /etc/postfix/master.cf
  * /etc/profile*
  * /etc/init.d/*
  * /etc/runlevels/*
  * /etc/ssh/*
  * /etc/ssl/*
  * /etc/systemd/*


### Redistribution note

As of version 1.13 Bubbagen now ships with the bindist USE flag pre-removed from the global make profile. This will cause a rebuild of several packages that depend on this USE flag when you run updates or install new software that has a dependency on one or more of these packages. Due to patent restrictions you may at that point no longer redistribute Bubbagen. To reinstate the bindist flag you should run the following command:

```
# USE="bindist" emerge --oneshot app-admin/bubbagen
```
This does not only set the bindist flag but also includes several package specific masks and USE flags required to handle conflicts with the bindist flag. When you are done installing your additional software and/or updates you can use the same command but now with `USE="-bindist"` to remove the bindist flag and related config files from portage settings.


## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to contact me! (gordon@bosvangennip.nl)

[![Buy me a beer!](https://raw.githubusercontent.com/gordonb3/cache/master/Algemeen/Buy%20me%20a%20beer!.png)](https://www.paypal.com/donate/?hosted_button_id=USJR8BWKEAEAL)

