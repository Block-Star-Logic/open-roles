# Open Roles on Ethereum

This provides support for open roles on the Ethereum blockchain

The **Open Roles** framework consists of there interfaces [IRoleManager.sol](https://github.com/Block-Star-Logic/open-roles/blob/82b9bebfe2a78a75d5e3f0540ab14207ffbd0e44/solidity/contracts/IRoleManager.sol), which provides role based execution control within 
your smart contract, [IRoleManagerAdmin.sol](https://github.com/Block-Star-Logic/open-roles/blob/82b9bebfe2a78a75d5e3f0540ab14207ffbd0e44/solidity/contracts/IRoleManagerAdmin.sol) which enables either manual or toolbased role management, and finally [IDelegateAdmin.sol](https://github.com/Block-Star-Logic/open-roles/blob/82b9bebfe2a78a75d5e3f0540ab14207ffbd0e44/solidity/contracts/IDelegateAdmin.sol) which is responsible specifically for Admin management. Admin management has been separately encapsulated due to the open nature of blockchain and the need to support delegated behaviour. 

Two implementations have been provided which are [RoleManager.sol](https://github.com/Block-Star-Logic/open-roles/blob/82b9bebfe2a78a75d5e3f0540ab14207ffbd0e44/solidity/contracts/RoleManager.sol) and [DelegateAdmin.sol](https://github.com/Block-Star-Logic/open-roles/blob/82b9bebfe2a78a75d5e3f0540ab14207ffbd0e44/solidity/contracts/DelegateAdmin.sol). 
