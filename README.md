# Ribbon Hat NFT

Converting our ERC20 tokens to NFTs one at a time plus support for onboarding new members.

## Deploy in testnet

Copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key,
your Rinkeby node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction.
Rinkeby is set up as the testnet network mainly because OpenSea is also deployed in it.
With a valid .env file in place, first deploy your contract:

```shell
npx hardhat run --network rinkeby scripts/deploy_rinkeby.js
rhatErc20 deployed to: 0x5Fe76F4d2FE5e8931876B02feB5F26F5d0afcf4F
rhatNft deployed to: 0x3577349618227AEC36512c782E1Fe1aBA154544b
```

The above command will deploy a brand new RHAT ERC20 contract and the RHAT NFT contract.
In order to verify the contracts on Etherscan, copy the deployment addresses and paste
them below respectively. Make sure to update the `./scripts/arguments.js` file to hold
the same parameters used by the deployment script for the NFT contract:

```shell
# verify the ERC20 contract
npx hardhat verify --network rinkeby 0x5Fe76F4d2FE5e8931876B02feB5F26F5d0afcf4F TestRHAT RHAT 64 0xBdC85027BCDBe20B3430523a773bf3008888FA9d
# verify the NFT contract
npx hardhat verify --network rinkeby --constructor-args ./scripts/arguments_rinkeby.js 0x3577349618227AEC36512c782E1Fe1aBA154544b
```

## Deploy in mainnet

```shell
npx hardhat run --network mainnet scripts/deploy_mainnet.js
npx hardhat verify --network mainnet --constructor-args ./scripts/arguments_mainnet.js <NFT_CONTRACT_ADDRESS>
```
