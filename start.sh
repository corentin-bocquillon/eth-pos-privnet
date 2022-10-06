#!/bin/bash

docker run --rm --name geth-genesis -it -v $(pwd)/execution:/execution -v $(pwd)/execution/genesis.json:/execution/genesis.json ethereum/client-go:latest --datadir=/execution init /execution/genesis.json

docker run --rm --name create-beacon-chain-genesis -it -v $(pwd)/consensus:/consensus prysmctl:latest testnet generate-genesis --num-validators=64 --output-ssz=/consensus/genesis.ssz --chain-config-file=/consensus/config.yml

docker-compose up -d
