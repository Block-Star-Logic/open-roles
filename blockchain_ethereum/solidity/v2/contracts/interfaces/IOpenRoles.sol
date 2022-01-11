//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

interface IOpenRoles { 


    // dApp scope
    function isAllowed(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) view external returns (bool _isAllowed);

    function isBarred(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) view external returns (bool _isBarred);

    function getRolesForDapp(string memory _dApp) view external returns (string [] memory _roleNames);

    function getContractsForDapp(string memory _dApp) view external returns (address [] memory _contacts, string [] memory _names);
    
    function getUserAddressesForRoleForDapp(string memory _dApp, string memory _role) view external returns (address [] memory _userAddresses);

    function getContractsForRoleForDapp(string memory _dApp, string memory _role) view external returns (address [] memory _contracts, string [] memory _names);

    function getFunctionPermissionsForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract) view external returns (string [] memory _functions);


    // contact scope 
    function isAllowed(address _contract, string memory _role, string memory _function, address _srcSender ) view external returns (bool _isAllowed);

    function isBarred(address _contract, string memory _role, string memory _function, address _srcSender ) view external returns (bool _isBarred);

    function getRolesForContract(address _contract) view external returns (string [] memory _roleNames);

    function getFunctionsForRoleforContract(address _contract, string memory _role) view external returns (string [] memory _functions);

    function getUserAddressesForRoleForContract(address _contract, string memory _role) view external returns (address [] memory _userAddresses);

    function getFunctionPermissionsForRoleForContract(address _contract, string memory _role) view external returns (string [] memory _functions);


            // derivative contract local 
    function addDerivativeContract(string memory _dApp, address _derivativeContractAddress, string memory _contractType) external returns (bool _added);

    function removeDerivativeContract(address _derivativeContractAddress) external returns (bool _removed);

        // roles for derivative contract
    function addRolesForDerivativeContract(address _derivativeContractAddress, string [] memory roles) external returns (bool _added);

    function removeRolesForDerivativeContract(address _derivativeContractAddress, string [] memory roles) external returns (bool _removed);

        // functions for derivative contract
    function addFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) external returns (bool _added);

    function removeFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) external returns (bool _removed);

        // users for derivative contract
    function addUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) external returns (bool _added);

    function removeUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) external returns (bool _removed);

}

