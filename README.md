### INSTRUCTIONS

1. Configure a .env to have variables for:
   - ALCHEMY_API_KEY
   - USER_PRIVATE_KEY for the deployed wallet balance
2. Compile smart contract npx hardhat compile
3. Test that smart contract functions work using npx hardhat test
4. Deploy smart contract to goerli network using: npx hardhat run --network goerli scripts/deploy.js
