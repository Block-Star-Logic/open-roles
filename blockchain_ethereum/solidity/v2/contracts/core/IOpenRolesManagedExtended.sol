//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "./IOpenRolesManaged.sol";

interface IOpenRolesManagedExtended is IOpenRolesManaged { 

    function hasDerivativeTypeAffiliation() view external returns (bool _hasDerivativeTypeAffiliation);

    function getDerivativeTypeAffiliation() view external returns (string [] memory _derivativeContractType, string [] memory _derivativeTypeRole);

    
    function hasDerivativeTypes() view external returns (bool _derivativeTypes);

    function getDerivativeTypes() view external returns (string [] memory _derivativeContractTypes);

    
    function hasDefaultRolesForDerivativeTypes(string memory _derivativeContractType) view external returns (string [] memory _roles);
    
    function getDefaultDerivativeTypeRoles(string memory _derivativeContractType) view external returns (string [] memory _derivativeTypeRoles);


    function hasDefaultFunctionsForRoleForDerivativeContractType(string memory _derivativeContactType, string memory _role) view external returns  (bool _hasFunctions);

    function getDefaultDerivativeContractTypeFunctonsForRole(string memory _derivativeContactType, string memory _role) view external returns  ( string [] memory _functions);

}