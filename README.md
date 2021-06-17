# Open Roles
 This is the Open Block Enterprise Initiative repository for open roles

The **Open Roles** framework consists of there interfaces IRoleManager.sol, which provides role based execution control within 
your smart contract, IRoleManagerAdmin.sol which enables either manual or toolbased role management, and finally IDelegateAdmin.sol which is responsible specifically for Admin management. Admin management has been separately encapsulated due to the open nature of blockchain and the need to support delegated behaviour. 

Two implementations have been provided which are RoleManager.sol and DelegateAdmin.sol. 