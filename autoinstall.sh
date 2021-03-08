#!/bin/sh

. /etc/os-release
PASSWORD=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 15 | xargs`
CONFIG="{\n\"server\":\"0.0.0.0\",\n\"server_port\":443,\n\"password\":\"$PASSWORD\",\n\"timeout\":30,\n\"method\":\"chacha20-ietf-poly1305\",\n\"fast_open\":true,\n\"reuse_port\": true,\n\"plugin\":\"obfs-server\",\n\"plugin_opts\":\"obfs=tls\",\n\"mode\": \"tcp_and_udp\"\n}"
IP=`wget -qO- digitalresistance.dog/myIp`
sudo apt install git wget -y

setup() {
echo "Активация обфускации..."
sudo apt-get -y install --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
git clone https://github.com/shadowsocks/simple-obfs.git
cd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
sudo make install

echo "Настройка Shadowsocks..."

cd /etc/shadowsocks/

sudo chown $USER /etc/shadowsocks/

sudo rm config.json

echo | sed "i$CONFIG" > config.json

echo "Настройка systemd..."

sudo systemctl start shadowsocks && sudo systemctl enable shadowsocks

echo "Ваши данные для подключения:\nIP:$IP\nPort: 443\nPassword: $PASSWORD\nEncryption: chacha20-ietf-poly1305\nPlugin: obfs-server\nPlugin options: obfs=tls"
echo "========================================================= УСТАНОВКА ЗАВЕРШЕНА ========================================================"
exit 0
}

ub_new_install() {
echo "Установка Shadowsocks..."
sudo apt install shadowsocks -y
setup
}


ub_old_install() {
echo "Установка Shadowsocks..."
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
sudo chown -R $USER /etc/apt/
echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" >> /etc/apt/sources.list
sudo apt install shadowsocks -y
setup
}

deb_new_install() {
echo "Установка Shadowsocks..."
sudo sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
sudo apt update
sudo apt -t stretch-backports install shadowsocks-libev -y
setup
}

deb_old_install() {
echo "Установка Shadowsocks..."
sudo sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sudo sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
sudo apt update
sudo apt -t jessie-backports-sloppy install shadowsocks-libev -y
setup
}

echo "========================================================== УСТАНОВКА НАЧАТА =========================================================="

case $VERSION_ID in
	8)
        deb_old_install
        ;;
	9)
        deb_new_install
        ;;
	14.04)
        ub_old_install
        ;;
	16.04)
        ub_new_install
        ;;
        16.10)
        ub_new_install
        ;;
        17.04)
        ub_new_install
        ;;
	17.10)
        ub_new_install
        ;;
	18.04)
        ub_new_install
        ;;
	20.04)
	ub_new_install
	;;
	*)
	echo $VERSION_ID
	echo "Ваша версия Linux не поддерживается!\nПоддерживается Ubuntu версии 14.04+ и Debian версии 8+"
	exit 1
	;;
esac
