#!/bin/sh
sudo apt-get update && sudo apt install -y git awk

PASSWORD=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 15 | xargs`
CONFIG="{\n\"server\":\"0.0.0.0\",\n\"server_port\":443,\n\"password\":\"$PASSWORD\",\n\"timeout\":30,\n\"method\":\"chacha20-ietf-poly1305\",\n\"fast_open\":true,\n\"reuse_port\": true,\n\"plugin\":\"obfs-server\",\n\"plugin_opts\":\"obfs=tls\",\n\"mode\": \"tcp_and_udp\"\n}"
VERSION=`awk '/^Description: Ubuntu [0-9]/ {print $3; exit;}' /usr/share/python-apt/templates/Ubuntu.info`
IP=`wget -qO- digitalresistance.dog/myIp`
echo "========================================================== Работа на версиях Ubuntu ниже 16.04 не гарантируется! =========================================================="

setup() {
echo "========================================================== УСТАНОВКА НАЧАТА =========================================================="
sudo apt install --no-install-recommends build-essential git autoconf libtool libssl-dev libpcre3-dev libc-ares-dev libev-dev asciidoc xmlto automake -y && sudo git clone https://github.com/shadowsocks/simple-obfs.git && cd simple-obfs && sudo git submodule update --init --recursive && sudo ./autogen.sh && sudo ./configure && sudo make && sudo make install

cd /etc/shadowsocks-libev/

sudo rm config.json

sudo echo "$CONFIG" > config.json

sudo systemctl start shadowsocks-libev $$ sudo systemctl enable shadowsocks-libev

echo "Ваши данные для подключения:\nIP:$IP\nPort: 443\nPassword: $PASSWORD\nEncryption: chacha20-ietf-poly1305\nPlugin: obfs-server\nPlugin options: obfs=tls"
echo "========================================================= УСТАНОВКА ЗАВЕРШЕНА ========================================================"
exit 0
}

new_install() {
sudo apt install shadowsocks-libev

setup
}


old_install() {
sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:max-c-lv/shadowsocks-libev -y

sudo apt install -y shadowsocks-libev

setup
}

case $VERSION in
        16.10)
        new_install
        ;;
        17.04)
        new_install
        ;;
	17.10)
        new_install
        ;;
	18.04)
        new_install
        ;;
	*)
	old_install
	;;
esac
