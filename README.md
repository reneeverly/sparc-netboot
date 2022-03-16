# sparc-netboot (wip)
Dockerfile and docker compose configuration for booting a locally attached SPARCstation IPC.

## Expected Outcome

Running NetBSD 9.2 "diskless" on the SPARCstation IPC.

Depending upon how slow that version runs on this ancient hardware, I might want to go with an older version.

### Rationale

SCSI2SD is out of stock, and I don't trust the SPARCstation's original hard disk.  Even if I do end up getting a SCSI2SD, this is at least a learning experience in network booting.

## Progress

These steps are as described at https://www.netbsd.org/docs/network/netboot/intro.sun.html.

Yes, the SPARCstation IPC is a SUN4C, not a SUN3, but I was having DHCP issues and it was reverting to bootparamd.  We'll see if it ends up being needed or not.

* [ ] Install and configure rarpd
* [ ] Install and configure bootparamd
* [ ] Install and configure tftpd
* [ ] Install and configure nfsd
* [ ] Extract client filesystem
