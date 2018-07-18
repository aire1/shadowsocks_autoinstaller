#!/bin/sh

export /etc/os-release
PASSWORD=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 15 | xargs`
CONFIG="{\n\"server\":\"0.0.0.0\",\n\"server_port\":443,\n\"password\":\"$PASSWORD\",\n\"timeout\":30,\n\"method\":\"chacha20-ietf-poly1305\",\n\"fast_open\":true,\n\"reuse_port\": true,\n\"plugin\":\"obfs-server\",\n\"plugin_opts\":\"obfs=tls\",\n\"mode\": \"tcp_and_udp\"\n}"
IP=`wget -qO- digitalresistance.dog/myIp`

setup() {
echo "Установка simple-obfs..."
sudo apt-get -y install --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
git clone https://github.com/shadowsocks/simple-obfs.git
cd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
sudo make install

cd /etc/shadowsocks-libev/
	
sudo rm config.json

sudo echo "$CONFIG" > config.json

sudo systemctl start shadowsocks-libev && sudo systemctl enable shadowsocks-libev

echo "Ваши данные для подключения:\nIP:$IP\nPort: 443\nPassword: $PASSWORD\nEncryption: chacha20-ietf-poly1305\nPlugin: obfs-server\nPlugin options: obfs=tls"
echo "========================================================= УСТАНОВКА ЗАВЕРШЕНА ========================================================"
exit 0
}

ub_new_install() {
echo "Устанавливаю Shadowsocks..."
sudo apt install -y shadowsocks-libev git
setup
}


ub_old_install() {
echo "Устанавливаю Shadowsocks..."
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
sudo apt install -y shadowsocks-libev git
setup
}

deb_new_install() {
sudo apt-get install -y git-core
echo "Устанавливаю Shadowsocks..."
sudo sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
sudo apt update
sudo apt -t stretch-backports install shadowsocks-libev
}

deb_old_install() {
sudo apt-get install -y git-core
echo "Устанавливаю Shadowsocks..."
sudo sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sudo sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
sudo apt update
sudo apt -t jessie-backports-sloppy install shadowsocks-libev
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
        old_install
        ;;
	16.04)
        old_install
        ;;
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
	18.04)
        new_install
        ;;	
	*)
	echo "Ваша версия Linux не поддерживается!\nПоддерживается Ubuntu версии 14.04+ и Debian версии 8+"
	exit 1
	;;
esac
