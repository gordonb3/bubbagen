# bubbagen

Bootable live-USB of Bubba OS for the Excito B3 miniserver, build on Gentoo (kernel 4.19.52 LTS - Gentoo stable)

## Description

<img src="https://raw.githubusercontent.com/gordonb3/cache/master/Bubba/Excito-B3.jpg" alt="Excito B3" width="250px" align="right"/>
This project is a spin-off from [Sakaki's gentoo-on-b3 project](https://github.com/sakaki-/gentoo-on-b3) and contains what was previously published as the `Special Edition` while the Bubba overlay was still in beta.

As with the original, this project contains a bootable, live-USB image for the Excito B3 miniserver. You can use it as a rescue disk, to play with Gentoo Linux, or as the starting point to install Gentoo Linux on your B3's main hard drive. You can even use it on a diskless B3. No soldering, compilation, or [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) flashing is required! You can run it without harming your B3's existing software; however, any changes you make while running the system *will* be saved to the USB (i.e., there is persistence).

The kernel used in the image is **5.10.27** from gentoo-sources, with the necessary code to temporarily switch off the L2 cache in early boot (per [this link](https://lists.debian.org/debian-boot/2012/08/msg00804.html)) prepended, and the kirkwood-b3 device tree blob appended.

The image may be downloaded from the link below and should work, without modification, whether your B3 has an internal hard drive fitted or not.

Variant | Init type | Version | Image
:--- | ---: | ---: | ---:
B3 with or without Internal Drive | openRC | 1.14.0 | [bubbagenb3img-1.14.0.xz](https://github.com/gordonb3/bubbagen/releases/download/v1.14/bubbagenb3img-1.14.0.xz)
B3 with or without Internal Drive | systemd | 1.14.5 | [bubbagenb3img-1.14.5.xz](https://github.com/gordonb3/bubbagen/releases/download/v1.14/bubbagenb3img-1.14.5.xz)

> Please read the instructions below before proceeding. Also please note that all images are provided 'as is' and without warranty.

## Prerequisites

To try this out, you will need:
* A USB key of at least 8GB capacity (the *uncompressed* image is 14,813,184 (512 byte) sectors = 7,584,350,208 bytes). Unfortunately, not all USB keys work with the various versions of [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) that were factory installed on the B3. Most SanDisk and Lexar USB keys appear to work reliably, but others (e.g., Verbatim keys) will not boot properly. (You may find the list of known-good USB keys [in this post](http://forum.doozan.com/read.php?2,1915,page=1) useful.)
* An Excito B3 (obviously!).
* A PC to decompress the image and write it to the USB key (of course, you can also use your B3 for this, assuming it is currently running the standard Excito / Debian Squeeze system). This is most easily done on a Linux machine of some sort, but tools are also available for Windows (see [here](http://tukaani.org/xz/) and [here](http://sourceforge.net/projects/win32diskimager/), for example). In the instructions below I'm going to assume you're using Linux.


## Downloading and Writing the Image

On your Linux box, issue:
```
# wget -c https://github.com/gordonb3/bubbagen/releases/download/v1.14/bubbagenb3img-1.14.0.xz
```
to fetch the compressed disk image file

Next, insert (into your Linux box) the USB key on which you want to install the image, and determine its device path (this will be something like `/dev/sdb`, `/dev/sdc` etc.; the actual path will depend on your system, you can use the `lsblk` tool to help you). Unmount any existing partitions of the USB key that may have automounted (using `umount`). Then issue:

> **Warning** - this will *destroy* all existing data on the target drive, so please double-check that you have the path correct!

```
# xzcat bubbagenb3img-1.14.0.xz > /dev/sdX && sync
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

> The image uses a solid green LED as its 'normal' state to show that your B3 is running from USB key. This should make it easy to identify whether your system booted from USB or hard drive (stock Sakaki gentoo-on-b3 will also show green LED when runing from harddrive)

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

For the main text on this, please refer to the [older README](https://github.com/gordonb3/bubbagen/blob/v1.14/reference/gentoo-on-b3-1.8.0-README.md) by Sakaki.


The following major changes to the original 1.8.0 release from Sakaki apply:

1. Both 1.14.x images now use the same generic kernel that is loaded through a second stage bootloader that allows you to change kernel command line parameters by simply editing a `boot.ini` file.

2. The image supplied kernel is version 5.10.27 and supports both openrc and systemd init systems. 

1. Both 1.14.x images have been brought up to date against the Gentoo tree as of 01 Jul 2021. The full set of packages in the image may be viewed [here (1.14.0)](https://github.com/gordonb3/bubbagen/blob/v1.14/reference/installed-packages-1.14.0) and [here (1.14.5)](https://github.com/gordonb3/bubbagen/blob/v1.14/reference/installed-packages-1.14.5).

1. The bubbagen images have sysvinit patched to follow the hardware specific routine for shutting down. As such you can now simply use `halt` or `poweroff` commands (Sakaki's `poweroff-b3` script is not available in this image) to shut down the B3.
> Please note that the B3 does not actually power down but enters a special pre boot environment where it waits for the button on the rear to be pressed. As multiple users discovered, this happens to be quite CPU intensive and the B3 may run quite hot and use more power than when running an OS.

Have fun! ^-^

## Changes since version 1.13

* disabled torrent support in net-p2p/filetransferdaemon
* consolidated the bubba admin packages to a single package
* removed build dependency on resources unfriendly ruby, nodejs and spidermonkey
* the bubbagen kernel is now a binary package
* added wireguard VPN support
* various developer language updates: gcc 10.3, php 7.4, perl 5.32
* due to Sakaki's retirement the following repositories have been cleaned and marked user_defined:
   * gentoo-b3: deleted all except sys-kernel/buildkernel-b3
   * sakaki-tools: deleted all except app-portage/genup and app-portage/showem
* systemd: corrected enforced dependency on systemd-resolved

## Changes since version 1.12

* various developer language updates: gcc 9.2, php 7.3, perl 5.30
* bootloader revision
* removed obsolete php cgi
* now using nftables as the firewall back-end
* dropped fixed ruby target -> portage wants to overrule it anyway
* fixed a memory allocating issue with forked-easyfind
* installer incorrectly used fdisk GPT commands with DOS partition tables
* some GUI commands would not be executed because the corresponding application was not inside the searchpath used by bubba-admin
* systemd version: service control failed because systemd paths were changed
* GUI updates:
    * empty postdata on lanupdate would cause the NIC to be set to dynamic IP
    * fix display of AllowRemote value for admin user
* replaced corrupted hosts file
* package related settings specific to this distribution are now owned by bubbagen package
* bindist USE flag pre-removed from global make profile

## Earlier changes

* corrected a problem in ghostscript
* fixed a kernel dependency (systemd)
* removed dependency on bubba-buttond for the B2
* explicitly listed `feroceon` USE flag for sys-apps/sysvinit to enforce election of the B3 patched version
* switched to Gentoo profile 17 (including full rebuild of all installed packages for position-independent loading)
* reorganized package masks, combining bindist USE flag conflicts in a single file
* improved install script behaviour (allow to keep home partition, create the correct partition table, ...)
* various updates and fixes to the bubba-overlay
* dropped mediatomb from package list (this package has in fact been unmanaged by the interface since Excito software version 2.4)
* java VM updated to openjdk 8
* fixed a cyclic dependency on bridge interface in hostapd
* fixed unability to print non-native documents (due to deadlock in Ghostscript)
* block enabling the WiFi AP when LAN is set to receive its IP through DHCP (causes network to fail)
* fixed a problem with restarting network interfaces in systemd version

## Miscellaneous Points

* The image is subscribed to the following overlays:
  * [`sakaki-tools`](https://github.com/sakaki-/sakaki-tools): this overlay (provided by Sakaki) provides the tools `showem` ([source](https://github.com/sakaki-/showem), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/showem.pdf)) and `genup` ([source](https://github.com/sakaki-/genup), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup.pdf)). (Note - these replace the old `showem-lite` and `genup-lite` tools.)
  * [`gentoo-b3`](https://github.com/sakaki-/gentoo-b3-overlay): this overlay (provided by Sakaki) provides a modern version of the `lzo` package ([upstream](http://www.oberhumer.com/opensource/lzo/download/); required because of an [alignment bug](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=757037#32)), and the `buildkernel-b3` tool ([source](https://github.com/sakaki-/buildkernel-b3), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)).
  * [`bubba`](https://github.com/gordonb3/bubba-overlay): this overlay provides the `Bubba OS` and `Logitech Media Server`. It also provides ebuilds for the home automation software Domoticz and supporting software; these have not been installed in the image, but you can easily `emerge` them if you like.
* Please note that the firewall, as initially configured, will allow `ssh` traffic on the `wan` port also.
* Apart from Apache web server to run the Bubba User Interface, Samba file sharing is also enabled by default
* Tor is not installed on the bubbagen image because of licensing issues with openssl. You may install it yourself but you should note that this will trigger a rebuild of several other packages (including openssl and openssh - careful!)
* There is no MySQL in the bubbagen image. Reason? It consumes too much memory (YMMV). Original Excito Bubba OS Services that used it have either been adapted to use SQLite instead, or been replaced by alternatives. Webmail is now served by Roundcube and bubba-album was dropped in favor of Singapore Gallery (sgal).
* If you have a WiFi-enabled B3, the corresponding network interface is named `wlan0` (there is a `udev` rule that does this, namely `/lib/udev/rules.d/70-net-name-use-custom.rules`). Please note that this rule will **not** work correctly if you have more than one WiFi adaptor on your B3 (an unusual setup).
* The image includes a 1GiB swap partition, and also has sufficient space in its root partition to e.g., perform a kernel compilation, should you so desire.
* If you have a USB key larger than the minimum 8GB, after writing the image you can easily extend the size of the second partition (using `fdisk` and `resize2fs`), so you have more space to work in. See [these instructions](http://geekpeek.net/resize-filesystem-fdisk-resize2fs/), for example.
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

Please refer to the corresponding section(s) in the [older README](https://github.com/gordonb3/bubbagen/blob/v1.14/reference/gentoo-on-b3-1.8.0-README.md) by Sakaki.


### Upgrading from a previous version of Bubbagen

**Warning** This will still clear your complete system and you will lose any additional packages you installed.

* make a backup of your /etc and /var/lib directories
* run the installer - make a note that it says it will keep /home before proceeding
* restore /var/lib
* restore /etc but keep the following files from the image (remove first, then copy):
  * /etc/portage/*
  * /etc/dovecot/*
  * /etc/php/*
  * /etc/postfix/master.cf
  * /etc/profile*
  * /etc/runlevels/*
  * /etc/ssh/*
  * /etc/ssl/*


### Redistribution note

As of version 1.13 Bubbagen now ships with the bindist USE flag pre-removed from the global make profile. This will cause a rebuild of several packages that depend on this USE flag when you run updates or install new software that has a dependency on one or more of these packages. Due to patent restrictions you may at that point no longer redistribute Bubbagen. To reinstate the bindist flag you should run the following command:

```
# USE="bindist" emerge --oneshot --nodeps app-admin/bubbagen
```
This does not only set the bindist flag but also includes several package specific masks and USE flags required to handle conflicts with the bindist flag. When you are done installing your additional software and/or updates you can use the same command but now with `USE="-bindist"` to remove the bindist flag and related config files from portage settings.


## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to contact me! (gordon@bosvangennip.nl)

