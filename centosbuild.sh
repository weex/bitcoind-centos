#!/bin/bash

if [ ! -x /usr/bin/wget ] ; then
 echo "for some silly reason, wget is not executable.  Please fix this (as root do chmod +x /usr/bin/wget) and try again"
 exit
fi

USERNAME=`whoami`
cd ~
mkdir Bitcoin
cd Bitcoin
mkdir Libraries
mkdir Trunk
mkdir Deps
cd Libraries

wget -qO- http://sourceforge.net/projects/boost/files/boost/1.49.0/boost_1_49_0.tar.bz2/download | tar xjv
cd boost_1_49_0
./bootstrap.sh
./bjam --prefix=/home/$USERNAME/Bitcoin/Deps link=static runtime-link=static install
cd ..

wget -qO- http://openssl.org/source/openssl-1.0.0g.tar.gz | tar xzv
cd openssl-1.0.0g
if uname -a | grep -q x86_64 ; then
 ./Configure no-shared --prefix=/home/$USERNAME/Bitcoin/Deps --openssldir=/home/$USERNAME/Bitcoin/Deps/openssl linux-x86_64
else
 ./Configure no-shared --prefix=/home/$USERNAME/Bitcoin/Deps --openssldir=/home/$USERNAME/Bitcoin/Deps/openssl linux-generic32
fi
#make depend
make
make install
cd ..

wget -qO- http://download.oracle.com/berkeley-db/db-5.1.19.tar.gz | tar xzv
cd db-5.1.19/build_unix
../dist/configure --prefix=/home/$USERNAME/Bitcoin/Deps/ --enable-cxx
make
make install
cd ../..

mkdir bitcoin-master
cd bitcoin-master
wget -qO- https://github.com/bitcoin/bitcoin/tarball/master --no-check-certificate | tar xzv --strip-components 1
cd src
#cp -vap ~$USERNAME/makefile.new .
cat /home/$USERNAME/makefile.new | sed s/kjj/$USERNAME/g > makefile.new
make -f makefile.new bitcoind
cp -vap bitcoind /home/$USERNAME/
cd ~
