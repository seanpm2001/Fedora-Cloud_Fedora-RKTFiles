#!/bin/sh
#
# Make a Rocket image tree for mongodb
#
SOURCE=""
DEST=image
ROOTFS=image/rootfs
BINFILES="/usr/bin/mongod /usr/bin/mongos /usr/bin/bash /usr/bin/ls /usr/bin/find"
#BINFILES="/usr/bin/mongod /usr/bin/mongos"
CONFIGFILE=/etc/mongodb.conf

rm -rf ${DEST}

mkdir -p ${ROOTFS}
mkdir -p ${ROOTFS}/etc
mkdir -p ${ROOTFS}/lib64
mkdir -p ${ROOTFS}/usr/bin
mkdir -p ${ROOTFS}/data/db
mkdir -p ${ROOTFS}/dev
touch ${ROOTFS}/dev/urandom

for BINFILE in ${BINFILES}
do
                echo -n "${BINFILE} " && rpm -qf --qf "%{NAME}\n" ${BINFILE}
		cp ${BINFILE} ${ROOTFS}${BINFILE}
		SHAREDOBJS=$(ldd ${BINFILE} | awk '{print $1}' | grep -e ^/)
		for SOFILE in ${SHAREDOBJS}
		do
                		echo -n "${SOFILE} " && rpm -qf --qf "%{NAME}\n" ${SOFILE}
				cp ${SOFILE} ${ROOTFS}${SOFILE}
		done
		SHAREDOBJS=$(ldd ${BINFILE} | awk '{print $3}' | grep -e ^/lib)
		for SOFILE in ${SHAREDOBJS}
		do
                		echo -n "${SOFILE} " && rpm -qf --qf "%{NAME}\n" ${SOFILE}
				cp ${SOFILE} ${ROOTFS}${SOFILE}
		done
		
done
echo -n "${CONFIGFILE} " && rpm -qf --qf "%{NAME}\n" ${CONFIGFILE}
cp ${CONFIGFILE} ${ROOTFS}${CONFIGFILE}

cp manifest ${DEST}

