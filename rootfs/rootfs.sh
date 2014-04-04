#!/bin/bash

function do_build
{
        $builder busybox $install_dir
#        $builder strace $install_dir
#        $builder dhcpcd $install_dir
}

set -e

if [[ $# -ne 1 ]]
then
	echo "usage: $(basename $0) install_dir"
	exit 1
fi

if [ -z "$TOOLCHAIN_PATH" ]
then
	echo "TOOLCHAIN_PATH variable is not set"
	exit 2
fi

target=$TARGET
scripts_dir=$(cd $(dirname $0) && pwd)
mkdir -p $1
install_dir=$(cd $1; pwd)
builder="$scripts_dir/../builder/builder.sh"

do_build

cd $install_dir
ln -s bin/busybox init
cd -

mkdir $install_dir/dev/
sudo mknod $install_dir/dev/ttyO0 c 204 64
cd $install_dir/dev/
sudo MAKEDEV -v generic console
cd -

mkdir $install_dir/etc
cp $scripts_dir/fstab $install_dir/etc
#cp $scripts_dir/inittab $install_dir/etc
#cp $scripts_dir/fstab $install_dir/etc
#cp $scripts_dir/group $install_dir/etc
#cp $scripts_dir/passwd $install_dir/etc
#cp $scripts_dir/shells $install_dir/etc
#cp $scripts_dir/hosts $install_dir/etc
test -e $install_dir/etc/shadow || cp $scripts_dir/shadow $install_dir/etc
chmod 400 $install_dir/etc/shadow

mkdir $install_dir/boot
cp $scripts_dir/boot/* $install_dir/boot

mkdir $install_dir/lib
cp -r $TOOLCHAIN_PATH/lib/* $install_dir/lib

cp -r $scripts_dir/init.d $install_dir/etc

mkdir $install_dir/proc
mkdir $install_dir/sys
mkdir $install_dir/tmp
mkdir $install_dir/run
mkdir $install_dir/sys/kernel
mkdir $install_dir/sys/kernel/debug
mkdir $install_dir/dev/pts
test -e $install_dir/sbin/dhcpcd || ln -s /usr/sbin/dhcpcd $install_dir/sbin/dhcpcd
mkdir $install_dir/usr/share/udhcp
cp $scripts_dir/default.script $install_dir/usr/share/udhcp/
sudo chmod +x $scripts_dir/default.script
