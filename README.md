# RHAT ERC20 to ERC721 converter

Converting our ERC20 tokens to NFTs one at a time.

## Deploy in testnet

Copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key,
your Rinkeby node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction.
Rinkeby is set up as the testnet network mainly because OpenSea is also deployed in it.
With a valid .env file in place, first deploy your contract:

```shell
npx hardhat run --network rinkeby scripts/deploy_rinkeby.js
```

Then, in order to verify the contract on Etherscan, copy the deployment address and paste it in to
replace `DEPLOYED_CONTRACT_ADDRESS` in this command. Make sure to update the `./scripts/arguments.js`
file to hold the same parameters used by the deployment script:

```shell
npx hardhat verify --network rinkeby --constructor-args ./scripts/arguments.js DEPLOYED_CONTRACT_ADDRESS
```

## Deploy in mainnet

```shell
npx hardhat run --network mainnet scripts/deploy_mainnet.js
```
