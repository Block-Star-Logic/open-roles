//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

interface IOpenRolesDerivativeTypesAdmin {


     // derivative contracts 

    function getDApp() view external returns (string memory _dApp);
        // listing functions 
    function listDerivativeContractTypes() view external returns (string [] memory _contractTypes);

    function listRolesForDerivativeContractType(string memory _derivativeContactType) view external returns (string [] memory _roles); 

    function listFunctionsForRoleForDerivativeContractType(string memory _derivativeContractType, string memory _role) view external returns (string [] memory _functions);
    
    function listUsersForRoleForDerivativeContractType(string memory _derivativeContractType, string memory _role) view external returns (address [] memory _userAddresses);
 
    
    // derivative contacts - derivative contracts can only be "owned" by one dApp but can be shared to other dApp contexts

        // dApp wide 
    function addDerivativeContractTypes( string [] memory _contractTypes) external returns (bool _added);

    function removeDerivativeContractTypes(string [] memory _contractTypes) external returns (bool _removed);

        // roles must exist in the DApp role list
    function mapRolesToContractType( string memory _contractType, string [] memory _role) external returns (bool _added);
    
    function unmapRolesFromContractType(string memory _contractType, string [] memory _role) external returns (bool _removed);


    function addFunctionsForRoleForDerivativeContactType(string memory _contractType, string memory _role, string [] memory _functions) external returns (bool _added);

    function removeFunctionsForRoleForDerivativeContactType( string memory _contractType, string memory _role, string [] memory _functions) external returns (bool _removed);

}