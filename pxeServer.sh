#!/bin/bash
dnsmasqFile="/etc/dnsmasq.conf"

function requirements(){
        apt-get -y install dnsmasq pxelinux syslinux-common
}
function tftpDirectory(){
        mkdir -p /var/lib/tftpboot 
        mkdir -p /var/libtftpboot/pxelinux.cfg
        ln -s /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/
        ln -s /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/
}

function generateDnsmasqConfig(){
    if [ -f $dnsmasqFile ];then
            rm -f $dnsmasqFile
    fi
    echo "port=0
    log-dhcp
    dhcp-range=$1,proxy 
    dhcp-boot=pxelinux.0
    pxe-service=x86PC,\"Network Boot\",pxelinux
    enable-tftp
    tftp-root=/var/lib/tftpboot">/etc/dnsmasq.conf
    echo "DNSMASQ_EXCEPT=l0" >> /etc/default/dnsmasq
}
function getUbuntu(){
        wget -O /tmp/ubuntuInstall.tar.gz http://archive.ubuntu.com/ubuntu/dists/cosmic/main/installer-amd64/current/images/netboot/netboot.tar.gz
        tar -xf /tmp/ubuntuInstall.tar.gz -C /var/lib/tftpboot
}
function startServices(){
        systemctl enable dnsmasq
        systemctl start dnsmasq
}
if [ $UID -ne 0 ];then
       echo "[!]This script must be run as root"
      exit
fi


requirements
tftpDirectory
generateDnsmasqConfig "192.168.56.0"
getUbuntu
startServices

