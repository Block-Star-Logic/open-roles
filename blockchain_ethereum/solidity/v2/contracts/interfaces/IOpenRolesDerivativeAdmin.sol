//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;


interface IOpenRolesDerivativesAdmin { 

    function getDApp() view external returns (string memory _dApp);

    function getLocalUsers(address _derivativeContractAddress) view external returns (address [] memory _userAddresses);

    function getRolesForContract(address _contract) view external returns (string [] memory _roleNames);
        
    function getFunctionsForRoleforContract(address _contract, string memory _role) view external returns (string [] memory _functions);

    function getUserAddressesForRoleForContract(address _contract, string memory _role) view external returns (address [] memory _userAddresses);

    function getDerivativeContractType(address _derivativeContract) view external returns (string memory _contractType);
    
    function isRegistered( address _derivativeContractAddress )view external returns (bool _isRegistered);


    function listDerivativeContracts() view external returns( address [] memory _derivativeContracts,  string [] memory _contractTypes); 
    
    function listDerivativeContractsForContractType(string memory _contractType) view external returns (address [] memory _derivativeContracts);

    function listDerivativeContractTypesForRole(string memory _role) view external returns (string [] memory _contractTypes);

    function listDerivativeContractsForRole(string memory _role) view external returns (address [] memory _derivativeContracts, string [] memory _contractTypes);

    function listDerivativeContractsForRoleForContractType(string memory _role, string memory _contractType ) view external returns (address [] memory _derivativeContracts);


    // derivative contracts 
    function addDerivativeContract( address _derivativeContractAddress, string memory _contractType) external returns (bool _added);

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