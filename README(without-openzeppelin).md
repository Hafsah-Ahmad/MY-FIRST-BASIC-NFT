This is a custom ERC-721 NFT smart contract implemented without OpenZeppelin, built for learning and portfolio purposes.
The contract is fully functional, supports payable minting, reserved tokens for the owner, and withdrawal of funds.

It follows the ERC-721 standard and includes gas optimizations using constant for fixed values.

Features=
-ERC-721 Standard → balanceOf, ownerOf, transferFrom, approvals, and events.
-Payable Minting → anyone can mint by paying the mint fee.
-Mint Limit per Wallet → max NFTs per wallet enforced.
-Reserved Supply → special reserved tokens that only the owner can mint.
-Metadata Support → tokenURI returns a base IPFS URI + tokenId.
-Withdraw Function → contract owner can withdraw ETH collected from minting.
-Gas Optimized → constants used for fixed values.

Contract Details=
-Name: Hafsa's1stNFT
-Symbol: HAFSO
-Max Supply: 500
-Mint Price: 0.03 ETH
-Per-Wallet Limit: 3
-Reserved Tokens for Owner: 50
-Start Token ID: 1

Getting Started=
1. Clone the repository
git clone https://github.com/y/hafsa-nft.git
cd hafsa-nft

2. Install dependencies (Hardhat project)
npm init -y
npm install --save-dev hardhat
npx hardhat


Choose Create a JavaScript project.

3. Add the contract

Save the contract in:
contracts/HafsasNFT.sol

4. Compile
npx hardhat compile