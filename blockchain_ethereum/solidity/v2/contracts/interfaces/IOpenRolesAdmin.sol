//"SPDX-License-Identifier: APACHE 2.0"

pragma solidity >=0.8.0 <0.9.0;

interface IOpenRolesAdmin {

    // listing function 

        // list dApps
    function listDapps() view external returns (string [] memory _dappList);

        // list dApp wide roles 
    function listRolesForDapp(string memory _dApp) view external returns(string [] memory _dappRoleList);

        // list core contracts in dApp
    function listContractsForDapp(string memory _dApp) view external returns (string [] memory _contractNames, address [] memory _contracts);

        // list core contracts for role in dApp 
    function listContractsForRoleForDapp(string memory _dapp, string memory _role) view external returns (string [] memory _contractNames, address[] memory _contractAddresses);

        // list functions on ctontract for dApp wide role for dApp
    function listFunctionsForRoleForContractForDapp(string memory _dApp, string memory _role, address _contractAddress) view external returns (string [] memory _functions); 

        // list user addreses assigned to dApp wide role 
    function listUsersForRole(string memory dApp, string memory _role) view external returns (address[] memory _userAddresses);

    // entity functions 

        // dApp 
    function addDapp(string memory _dApp) external returns (bool _added);

    function removeDapp(string memory _dApp) external returns (bool _removed);

    
        // dApp wide roles
    function addRolesForDapp(string memory _dApp, string [] memory _roleNames) external returns ( bool _added);

    function removeRolesForDapp(string memory _dApp, string [] memory roleNames) external returns (bool _removed);

    
        // dApp core contracts
    function addContractsForDapp(string memory _dApp, address [] memory _contracts, string [] memory _contractName) external returns (bool _added);

    function removeContractsForDapp(string memory _dApp, address [] memory _contracts) external returns (bool _removed);    


    // mapping functions 

        // add users to dApp wide role 
    function addUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) external returns (bool _added);

    function removeUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) external returns (bool _removed);

        // add core contracts for dApp wide role 
    function addContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) external returns (bool _added);

    function removeContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) external returns (bool _removed);
    
        // add functions for contract for dApp wide role 
    function addFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) external returns (bool _added);

    function removeFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) external returns (bool _removed);

     
     // derivative contracts 

        // listing functions 
    function listDerivativeContractTypesForDapp(string memory dApp) view external returns (string [] memory _contractTypes);

    function listRolesForDerivativeContractType(string memory dApp, string memory _derivativeContactType) view external returns (string [] memory _roles); 

    function listFunctionsForRoleForDerivativeContractType(string memory _dApp, string memory _derivativeContractType, string memory _role) view external returns (string [] memory _functions);


    function listDerivativeContractsForDapp(string memory _dApp) view external returns( string [] memory _contractTypes, address [] memory _derivativeContracts); 

    function listDerivativeContractsForContractType(string memory _dApp, string memory _contractType) view external returns (address [] memory _derivativeContracts);


    function listDerivativeContractTypesForRole(string memory _dApp, string memory _role) view external returns (string [] memory _contractTypes);

    function listDerivativeContractsForRole(string memory _dApp, string memory _role) view external returns (address [] memory _derivativeContracts, string [] memory _contractTypes);

    function listDerivativeContractsForRoleForContractType(string memory _dApp,  string memory _role, string memory _contractType ) view external returns (address [] memory _derivativeContracts);

        // derivative contract listing
    function listRolesForDerivativeContract(address _derivativeContract) view external returns (string [] memory _roles); 

    function listFunctionsForRoleForDerivativeContract(address _derivativeContract, string memory _role) view external returns (string [] memory _functions);

    function listUsersForRoleForDerivativeContract(address _derivativeContract, string memory _role) view external returns (address [] memory _userAddresses);

    
    // derivative contacts - derivative contracts can only be "owned" by one dApp but can be shared to other dApp contexts

        // dApp wide 
    function addDerivativeContractTypesForDapp(string memory _dApp, string [] memory _contractTypes) external returns (bool _added);

    function removeDerivativeContractTypesForDapp(string memory _dApp, string [] memory _contractTypes) external returns (bool _removed);

    // map is used because the values are already known internal to OpenRolesAdmin
    function mapRolesToContractType(string memory _dApp, string memory _contractType, string [] memory _role) external returns (bool _added);
    
    function unmapRolesFromContractType(string memory _dApp, string memory _contractType, string [] memory _role) external returns (bool _removed);


    function addFunctionsForRoleForDerivativeContactType(string memory _dApp, string memory _contractType, string memory _role, string [] memory _functions) external returns (bool _added);

    function removeFunctionsForRoleForDerivativeContactType(string memory _dApp, string memory _contractType, string memory _role, string [] memory _functions) external returns (bool _removed);


}