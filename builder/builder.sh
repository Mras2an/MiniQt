#!/bin/bash

set -e

function do_unpack_std
{
	wget -c $URL
	tar xf $PKG_file
	cd $PKG-$PKG_ver
}

function do_compile_std
{
	./configure --prefix=$install_dir/usr		\
		    --libdir=$install_dir/usr/lib	\
		    --host=$target
	make
}

function do_install_std
{
	make install
	cd ..
}

if [[ $# -ne 2 ]]
then
	echo "usage: $(basename $0) pkg rootfs_prefix"
	exit 1
fi

scripts_dir=$(cd $(dirname $0) && pwd)
build=x86_64-unknown-linux-gnu
target=$TARGET

source $scripts_dir/pkgs/$1.pkg
install_dir=$2

mkdir -p work
cd work

export CC=$target-gcc
export CXX=$target-g++
export AR=$target-ar
export AS=$target-as
export RANLIB=$target-ranlib
export LD=$target-ld
export STRIP=$target-strip

err=0

do_unpack
if [[ $err != 0 ]]
then
	echo "do_unpack failed"
	cd ..
	rm -rf work
	exit $ret
fi
do_compile
do_install

cd ..
rm -rf work

