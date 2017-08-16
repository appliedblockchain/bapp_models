set -x
# set -e

mkdir -p ~/tmp && cd ~/tmp

# this requires sudo unfortunately
wget http://parity-downloads-mirror.parity.io/v1.3.10/x86_64-unknown-linux-gnu/parity_1.3.10_amd64.deb && sudo dpkg -i parity_1.7.0_amd64.deb

npm i -g pm2

git clone https://$GH_TOKEN@github.com/appliedblockchain/bapp_parity.git && cd bapp_parity

# install dependencies
./bin/setup

./pm2_start

# deploy
./bin/setup

# copy contract configs
cp -r ../bapp_parity/config/contracts/* spec/integration/config/contracts/
