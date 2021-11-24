# Ribbon Hat NFT

Converting our ERC20 tokens to NFTs one at a time.

## Deploy in testnet

Copy the `.env.example` file to `.env`, and then edit it to fill in the missing details:
* an Etherscan API key (needed only to verify the contract)
* an Ethereum node URL (eg from Alchemy)
* the private key of the account which will send the deployment transaction

Rinkeby is set up as the testnet network because OpenSea is also deployed in it.
With a valid `.env` file in place:

```shell
npx hardhat run --network rinkeby scripts/deploy_rinkeby.js
```

The above command will deploy a brand new RHAT ERC20 contract and the RHAT NFT contract.
In order to verify the contracts on Etherscan, copy the deployment addresses and paste
them below respectively. Make sure to update the `./scripts/arguments.js` file to hold
the same parameters used by the deployment script for the NFT contract:

```shell
# verify the ERC20 contract
npx hardhat verify --network rinkeby <ERC20_CONTRACT_ADDRESS> TestRHAT RHAT 64 0xBdC85027BCDBe20B3430523a773bf3008888FA9d
# verify the NFT contract
npx hardhat verify --network rinkeby --constructor-args ./scripts/arguments_rinkeby.js <NFT_CONTRACT_ADDRESS>
```

[disperse.app](https://disperse.app/) can be used to distribute ERC20 tokens to multiple addresses at once.

## Deploy in mainnet

```shell
npx hardhat run --network mainnet scripts/deploy_mainnet.js
npx hardhat verify --network mainnet --constructor-args ./scripts/arguments_mainnet.js <NFT_CONTRACT_ADDRESS>
```
