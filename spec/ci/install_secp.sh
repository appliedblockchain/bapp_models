set -x
set -e

# sudo apt-get install -y libtool # already present on circle/travis

cd ~/

# skipping build and make for CI speed up
if [ ! -d secp256k1 ]; then
  git clone https://github.com/bitcoin-core/secp256k1
fi

cd secp256k1

if [ ! -d .libs ]; then
  ./autogen.sh
  ./configure  --prefix=$HOME --enable-module-recovery

  make
fi

make install
