# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
# Author: Renée Waverly Sonntag

# Stable debian release
# Original docs use woody, but that's severly outdated.
# Let's start out with the oldest available from dockerhub.
from debian/squeeze
shell ["/bin/bash", "-c"]

# Ensure up to date, then install the daemons we need
run apt update \
   && apt upgrade \
   && apt install rarpd bootparamd tftpd nfsd

# Download the NetBSD release, then extract it to the appropriate folder
run curl https://cdn.netbsd.org/pub/NetBSD/NetBSD-9.2/images/NetBSD-9.2-sparc.iso > release.iso \
   && mkdir /mnt/NetBSD-release \
   && mount -o loop release.iso /mnt/NetBSD-release \
   && mkdir -p /export/client \
   && cp -r /mnt/NetBSD-release /export/client

# Set up rarpd
run echo "08:00:20:0d:45:7b flop" > /etc/ethers \
   && echo "192.168.252.176 flop" > /etc/hosts \
   && echo "192.168.252.180 nfsserver" >> /etc/hosts
# rarpd -A

# Set up bootparamd
run echo "flop root=nfsserver:/export/client/root" > /etc/bootparams
# rpc.bootparamd -d

# Set up tftpd, TODO: pull ip to hex from old config
run mkdir -p /tftpboot \
   && cp /export/client/root/usr/mdec/boot /tftpboot/C0A8FCB0.SUN4C \
   && echo "tftp dgram udp wait nobody /usr/sbin/tcpd in.tftpd /tftpboot" >> /etc/inetd.conf

# set up nfsd
run mkpdir -p /export/client/root/dev \
   && mkdir /export/client/usr \
   && mkdir /export/client/home \
   && touch /export/client/swap \
   && cd /export/client/root
   && tar --numeric-owner -xvpzf /export/client/NetBSD-release/binary/sets/kern.tgz \
   && mknod /export/client/root/dev/console c 0 0 \
   && echo "/export/client/root client.test.net(rw,no_root_squash)" > /etc/exports \
   && echo "/export/client/swap client.test.net(rw,no_root_squash)" >> /etc/exports
   && echo "/export/client/usr client.test.net(rw,root_squash)" >> /etc/exports
   && echo "/export/client/home client.test.net(rw,root_squash)" >> /etc/exports

# set up the client filesystem
workdir /export/client/root
run tar --numeric-owner -xvpzf /export/client/NetBSD-release/binary/sets/base.tgz \
   && tar --numeric-owner -xvpzf /export/client/NetBSD-release/binary/sets/etc.tgz \
   && mkdir /export/client/root/kern \
   && mkdir /export/client/root/swap \
   && dd if=/dev/zero of=/export/client/swap bs=4k count=4k
