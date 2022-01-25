//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;


import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "../openblock/LOpenUtilities.sol";

import "../interfaces/IOpenRolesDerivativeTypesAdmin.sol";

import "../interfaces/IOpenRolesAdminInternal.sol";

import "../interfaces/IOpenRoles.sol";


contract OpenRolesDerivativeTypesAdmin is IOpenVersion, IOpenRolesDerivativeTypesAdmin {

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    
    uint256 version = 4; 
    string name; 
    string dApp; 
    IOpenRoles ior; 
    address self; 

    IOpenRolesAdminInternal iorai; 
    
    string adminRole    = "DERIVATIVE_CONTRACTS_ADMIN_ROLE";
    string sysAdminRole = "SYS_ADMIN_ROLE";

    constructor( string memory _name, string memory _dApp, address _openRolesAdminInternalAddress, address _openRolesAddress) {        
        name = _name;
        dApp = _dApp; 
        self = address(this);
        iorai = IOpenRolesAdminInternal(_openRolesAdminInternalAddress);          
        ior = IOpenRoles(_openRolesAddress); 
      
    }

  // derivative contracts 

        // listing functions    
    
    string [] contractTypes; 
    mapping(string=>bool) isKnownDerivativeContractTypeByContractType;     

    mapping(string=>string[]) derivativeContactTypesByRole; 
    mapping(string=>string[]) rolesByDerivativeContractType; 
    
    mapping(string=>mapping(string=>bool)) isKnownMappingByContractTypeByRole; 
    
    mapping(string=>mapping(string=>string[])) functionsByDerivativeContractTypeByRole;     
    mapping(string=>mapping(string=>mapping(string=>bool))) isKnownFunctionByContractTypeByRole;

    mapping(string=>mapping(string=>address[])) usersByRoleByContractType; 
    

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }

    function getDApp() override view external returns (string memory _dApp) {
        return dApp; 
    }

     // derivative contracts 
    function listDerivativeContractTypes() override  view external returns (string [] memory _contractTypes){
        return contractTypes; 
    }   

    function listRolesForDerivativeContractType(string memory _derivativeContractType) override view external returns (string [] memory _roles){
        return rolesByDerivativeContractType[_derivativeContractType];
    } 

    function listFunctionsForRoleForDerivativeContractType(string memory _derivativeContractType, string memory _role) override view external returns (string [] memory _functions){
        return functionsByDerivativeContractTypeByRole[_role][_derivativeContractType]; 
    }
    
    function listUsersForRoleForDerivativeContractType(string memory _derivativeContractType, string memory _role) override view external returns (address [] memory _userAddresses){
        return usersByRoleByContractType[_derivativeContractType][_role];
    }
    
    // derivative contacts - derivative contracts can only be "owned" by one dApp but can be shared to other dApp contexts

        // dApp wide 
    function addDerivativeContractTypes(string [] memory _contractTypes) override external returns (bool _added){
        ior.isAllowed(dApp, adminRole, self, "addDerivativeContractTypes", msg.sender);       

        for(uint256 x = 0; x < _contractTypes.length; x++){
            string memory contractType_ = _contractTypes[x];
            require(!isKnownDerivativeContractTypeByContractType[contractType_], string(" Open Roles Admin : addDerivativeContractTypesForDapp : 00 : attempt to add known contract Type :- ").append(contractType_));            
            contractTypes.push(contractType_);  
            isKnownDerivativeContractTypeByContractType[contractType_] = true;
        }
        return true;
    }

    function removeDerivativeContractTypes( string [] memory _contractTypes) override external returns (bool _removed){
         ior.isAllowed(dApp, adminRole, self, "removeDerivativeContractTypes", msg.sender);
        
        string [] memory remainingContractTypes_ = new string[](contractTypes.length - _contractTypes.length);
        
        uint256 y = 0; 
        for(uint256 x = 0; x < _contractTypes.length; x++){
            string memory contractType_ = _contractTypes[x];
            if(contractType_.isContained(contractTypes)){
                unmapRolesFromContractTypeInternal(contractType_, rolesByDerivativeContractType[contractType_]);
                isKnownDerivativeContractTypeByContractType[contractType_] = false; 
            }
            else {
                remainingContractTypes_[y] = contractType_;
                y++;
            }            
        }
        contractTypes = remainingContractTypes_;
        return true;
    }

    // map is used because the values are already known internal to OpenRolesAdmin
    function mapRolesToContractType( string memory _contractType, string [] memory _roles) override external returns (bool _mapped){
         ior.isAllowed(dApp, adminRole, self, "mapRolesToContractType", msg.sender);

        require(isKnownDerivativeContractTypeByContractType[_contractType], string(" Open Roles Admin : mapRolesToContractType : 00 : attempt to map unknown contract Type : ").append(_contractType));  
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x];
            
            require(iorai.isKnownRoleByDappInternal(dApp,role_), string(" Open Roles Admin : mapRolesToContractType : 01 : attempt to map unknown role : ").append(role_));
            require(!isKnownMappingByContractTypeByRole[role_][_contractType], string(" Open Roles Admin - mapRolesToContractType : 02 : attempt to create known mapping : ").append(role_).append(" : ").append(_contractType));

            rolesByDerivativeContractType[_contractType].push(role_);        
            derivativeContactTypesByRole[role_].push(_contractType);    

            isKnownMappingByContractTypeByRole[role_][_contractType] = true;       
        }
        return true;
    }
    
    function unmapRolesFromContractType( string memory _contractType, string [] memory _roles) override external returns (bool _unmapped){
        ior.isAllowed(dApp, adminRole, self, "unmapRolesFromContractType", msg.sender);   
        return unmapRolesFromContractTypeInternal(_contractType, _roles);
    }

    function addFunctionsForRoleForDerivativeContactType( string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _added){
        ior.isAllowed(dApp, adminRole, self, "addFunctionsForRoleForDerivativeContactType", msg.sender);
        require(isKnownMappingByContractTypeByRole[_role][_contractType],"");
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            require(!isKnownFunctionByContractTypeByRole[_role][_contractType][function_], string(" Open Roles Admin : addFunctionsForRoleForDerivativeContactType : 00 : attempt to add existing function to contract type to role : ").append(function_).append(" : ").append(_contractType).append(" : ").append(_role));
            functionsByDerivativeContractTypeByRole[_role][_contractType].push(function_);
            isKnownFunctionByContractTypeByRole[_role][_contractType][function_] = true; 
        }
        return true;
    }

    function removeFunctionsForRoleForDerivativeContactType( string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _removed){
         ior.isAllowed(dApp, adminRole, self, "removeFunctionsForRoleForDerivativeContactType", msg.sender);
        return removeFunctionsForRoleForDerivativeContactTypeInternal(_contractType, _role, _functions);
    }

    function unmapRolesFromContractTypeInternal(string memory _contractType, string [] memory _roles) internal returns(bool _unmapped) {
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x]; 
            require(isKnownMappingByContractTypeByRole[role_][_contractType], string(" Open Roles Admin : unmapRolesFromContractType : 02 : attempt to unmap unknown mapping ").append(role_).append(" : ").append(_contractType) );

            // remove reverse mapping
            rolesByDerivativeContractType[_contractType] = role_.remove(rolesByDerivativeContractType[_contractType]);
            // remove forward mapping
            derivativeContactTypesByRole[role_] = _contractType.remove(derivativeContactTypesByRole[role_]);
            // remove functions
            removeFunctionsForRoleForDerivativeContactTypeInternal(_contractType, role_, functionsByDerivativeContractTypeByRole[role_][_contractType]);
            
            isKnownMappingByContractTypeByRole[role_][_contractType] = false; 
        }
        return true; 
    }

    function setOpenRolesAdminInternal(address _openRolesAdminInternalAddress) external returns (bool _set){
        ior.isAllowed(dApp, sysAdminRole, self, "setOpenRolesAdminInternal", msg.sender);
        iorai = IOpenRolesAdminInternal(_openRolesAdminInternalAddress);
        return true;
    }

    function setOpenRoles(address _openRolesAddress) external returns (bool _set){
        ior.isAllowed(dApp, sysAdminRole, self, "setOpenRoles", msg.sender);
        ior = IOpenRoles(_openRolesAddress); 
        return true; 
    }
    //=======================================================================================

    function removeFunctionsForRoleForDerivativeContactTypeInternal(string memory _contractType, string memory _role, string [] memory _functions) internal returns (bool _removed) { 
        require(isKnownMappingByContractTypeByRole[_role][_contractType], string(" Open Roles Admin : addFunctionsForRoleForDerivativeContactType : 00 : attempt to remove functions for unknown mapping : ").append(_contractType).append(" : ").append(_role));
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            functionsByDerivativeContractTypeByRole[_role][_contractType] = function_.remove(functionsByDerivativeContractTypeByRole[_role][_contractType]);
            isKnownFunctionByContractTypeByRole[_role][_contractType][function_] = false; 
        }
        return true; 
    }
}