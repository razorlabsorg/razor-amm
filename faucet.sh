#!/bin/bash

# Infinite loop to request funds from faucet
while true; do
    echo "Requesting funds from faucet..."
    aptos account fund-with-faucet
    sleep 1
done 