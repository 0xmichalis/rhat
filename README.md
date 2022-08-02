# Ribbon Hat NFT

Converting our ERC20 tokens to NFTs one at a time.

## Build

```
forge build
```

## Test

```
forge test
```

## Deploy

```shell
forge create --rpc-url <your_rpc_url> \
    --constructor-args-path ./script/arguments_testnet.json \
    --private-key <your_private_key> src/RibbonHat.sol:RibbonHat \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```
