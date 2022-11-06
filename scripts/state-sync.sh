# BZE state sync script - EXPERIMENTAL - use on your own risk. 
# It is recommended to have bash scripting experience to understand what this script does for you
# Special thanks to our community member and validator MZONDER
# request
SNAP_RPC="https://rpc.getbze.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 3000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

#replace with your own data dir
DATA_DIR="$HOME/.bze"

if [ ! -d "$DATA_DIR" ] 
then
    echo "Data directory does NOT EXIST! Change your data dir to the correct one." 
    exit 1
fi

if [ ! -d "$DATA_DIR/data" ] 
then
    echo "Data directory does NOT contain blockchain data." 
    exit 2
fi

if [ ! -d "$DATA_DIR/config" ] 
then
    echo "Data directory does NOT contain config directory." 
    exit 3
fi

if [ ! -f "$DATA_DIR/config/config.toml" ] 
then
    echo "Data directory does NOT contain config.toml file." 
    exit 4
fi

if [ ! -f "$DATA_DIR/data/priv_validator_state.json" ] 
then
    echo "Data directory does NOT contain priv_validator_state.json file!" 
    exit 5
fi

# check
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
# output example
# 577601 576601 911319CF30E84C03ADD37B3BD1F5BBACFCB9FEDDBFECD051368F1659C5B822DD

# if OUTPUT ok - do next

# reset state
echo "Preparing to stop and delete node data"
sudo systemctl stop bzed && bzed tendermint unsafe-reset-all --home $DATA_DIR --keep-addr-book

#cp $DATA_DIR/data/priv_validator_state.json $DATA_DIR/
#rm -rf $DATA_DIR/data/*
#mv $DATA_DIR/priv_validator_state.json $DATA_DIR/data/
#sleep 5
echo "Stopped! Deleted blockchain data."

#add peer a9fac0534bd6853f5810fdc692564967bd01b1fe@144.91.122.246:26656
#peers="d1ce4dbdc45d33f6021e81127d99158cc4c72561@65.21.79.114:26656"
#sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.bze/config/config.toml
echo "Preparing to add fetched trust block..."
# config
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $DATA_DIR/config/config.toml
echo "Block added to config.toml"

# restart
echo "Starting BZE and tailing the journal"
echo "Wait until discover and apply snapshot (interrupt logs with CTRL+C)"
sudo systemctl start bzed && journalctl -fu bzed -o cat | grep snapshot
# wait until discover and apply snapshot (interrupt logs with CTRL+C)
