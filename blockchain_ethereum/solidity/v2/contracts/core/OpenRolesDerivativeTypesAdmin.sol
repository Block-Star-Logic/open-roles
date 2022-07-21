//SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.15;


import "https://github.com/Block-Star-Logic/open-version/blob/e161e8a2133fbeae14c45f1c3985c0a60f9a0e54/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "https://github.com/Block-Star-Logic/open-libraries/blob/703b21257790c56a61cd0f3d9de3187a9012e2b3/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "../interfaces/IOpenRolesDerivativeTypesAdmin.sol";

import "../interfaces/IOpenRolesAdminInternal.sol";

import "../interfaces/IOpenRoles.sol";

import "../interfaces/IOpenRolesManaged.sol";


contract OpenRolesDerivativeTypesAdmin is IOpenVersion, IOpenRolesManaged, IOpenRolesDerivativeTypesAdmin {

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    
    uint256 version = 11; 
    string name = "RESERVED_OPEN_ROLES_DERIVATIVE_TYPES_ADMIN"; 
    string dApp; 
    IOpenRoles ior; 
    address self; 

    IOpenRolesAdminInternal iorai; 
    
    string derivativeContractsAdminRole    = "DERIVATIVE_CONTRACTS_ADMIN_ROLE";
    string openAdminRole                   = "RESERVED_OPEN_ADMIN_ROLE";

    string [] roleNames = [derivativeContractsAdminRole, openAdminRole]; 
    mapping(string=>bool) hasDefaultFunctionsByRole; 
    mapping(string=>string[]) defaultFunctionsByRole; 

    constructor( string memory _dApp, address _openRolesAdminInternalAddress, address _openRolesAddress) {        
        
        dApp = _dApp; 
        self = address(this);
        iorai = IOpenRolesAdminInternal(_openRolesAdminInternalAddress);          
        ior = IOpenRoles(_openRolesAddress); 
        initDefaultRoleConfiguration();       
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

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }

    function getDefaultRoles() override view external returns (string [] memory _roleNames){
        return roleNames;
    }

    function hasDefaultFunctions(string memory _role) override view external returns(bool _hasFunctions){
        return hasDefaultFunctionsByRole[_role];
    } 

    function getDefaultFunctions(string memory _role) override view external returns (string [] memory _functions){
        return defaultFunctionsByRole[_role];
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
        require(isKnownMappingByContractTypeByRole[_role][_derivativeContractType],string(" Open Roles Derivative Types Admin : listUsersForRoleForDerivativeContractType : 00 : unknown mapping contract type <-> role :- ").append(_derivativeContractType).append(string(" <-> ")).append(_role));
        return iorai.listUsersForRoleInternal(dApp, _role);
    }
    
    // derivative contacts - derivative contracts can only be "owned" by one dApp but can be shared to other dApp contexts

        // dApp wide 
    function addDerivativeContractTypes(string [] memory _contractTypes) override external returns (bool _added){
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "addDerivativeContractTypes", msg.sender)," Open Roles Derivative Types Admin : addDerivativeContractTypes : 00 : authorised roles only ");       

        for(uint256 x = 0; x < _contractTypes.length; x++){
            string memory contractType_ = _contractTypes[x];
            require(!isKnownDerivativeContractTypeByContractType[contractType_], string(" Open Roles Derivative Types Admin : addDerivativeContractTypes : 01 : attempt to add known contract Type :- ").append(contractType_));            
            contractTypes.push(contractType_);  
            isKnownDerivativeContractTypeByContractType[contractType_] = true;
        }
        return true;
    }

    function removeDerivativeContractTypes( string [] memory _contractTypes) override external returns (bool _removed){
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "removeDerivativeContractTypes", msg.sender)," Open Roles Derivative Types Admin : removeDerivativeContractTypes : 00 : authorised roles only  ");
        
        string [] memory remainingContractTypes_ = new string[](contractTypes.length);
                
        uint256 y = 0; 
        for(uint256 x = 0; x < contractTypes.length; x++){
            string memory contractType_ = contractTypes[x];
            if(contractType_.isContained(_contractTypes)){
                unmapRolesFromContractTypeInternal(contractType_, rolesByDerivativeContractType[contractType_]);
                isKnownDerivativeContractTypeByContractType[contractType_] = false; 
            }
            else {
                remainingContractTypes_[y] = contractType_;
                y++;
            }            
        }

        string [] memory a = new string[](y);
        for(uint256 z = 0; z < y; z++) {
            a[z] = remainingContractTypes_[z];
        }
        contractTypes = a;
        return true;
    }

    // map is used because the values are already known internal to OpenRolesAdmin
    function mapRolesToContractType( string memory _contractType, string [] memory _roles) override external returns (bool _mapped){
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "mapRolesToContractType", msg.sender)," Open Roles Derivative Types Admin : mapRolesToContractType : 00 : authorised roles only ");

        require(isKnownDerivativeContractTypeByContractType[_contractType], string(" Open Roles Derivative Types Admin : mapRolesToContractType : 01 : attempt to map unknown contract Type : ").append(_contractType));  
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x];
            
            require(iorai.isKnownRoleByDappInternal(dApp,role_), string(" Open Roles Derivative Types Admin : mapRolesToContractType : 02 : attempt to map unknown role : ").append(role_));
            require(!isKnownMappingByContractTypeByRole[role_][_contractType], string(" Open Roles Derivative Types Admin - mapRolesToContractType : 03 : attempt to create known mapping : ").append(role_).append(" : ").append(_contractType));

            rolesByDerivativeContractType[_contractType].push(role_);        
            derivativeContactTypesByRole[role_].push(_contractType);    

            isKnownMappingByContractTypeByRole[role_][_contractType] = true;       
        }
        return true;
    }
    
    function unmapRolesFromContractType( string memory _contractType, string [] memory _roles) override external returns (bool _unmapped){
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "unmapRolesFromContractType", msg.sender)," Open Roles Derivative Types Admin : unmapRolesFromContractType : 00 : authorised roles only ");   
        return unmapRolesFromContractTypeInternal(_contractType, _roles);
    }

    function addFunctionsForRoleForDerivativeContactType( string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _added){ 
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "addFunctionsForRoleForDerivativeContactType", msg.sender), " Open Roles Derivative Types Admin : addFunctionsForRoleForDerivativeContactType : 00 : authorised roles only ");        
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            if(!isKnownFunctionByContractTypeByRole[_role][_contractType][function_]){
                functionsByDerivativeContractTypeByRole[_role][_contractType].push(function_);
                isKnownFunctionByContractTypeByRole[_role][_contractType][function_] = true; 
            }
        }
        return true;
    }

    function removeFunctionsForRoleForDerivativeContactType( string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _removed){
        require(ior.isAllowed(dApp, derivativeContractsAdminRole, self, "removeFunctionsForRoleForDerivativeContactType", msg.sender)," Open Roles Derivative Types Admin : removeFunctionsForRoleForDerivativeContactType : 00 : authorised roles only");
        return removeFunctionsForRoleForDerivativeContactTypeInternal(_contractType, _role, _functions);
    }

    function setOpenRolesAdminInternal(address _openRolesAdminInternalAddress) external returns (bool _set){
        require(ior.isAllowed(dApp, openAdminRole, self, "setOpenRolesAdminInternal", msg.sender)," Open Roles Derivative Types Admin : setOpenRolesAdminInternal : 00 : authorised roles only");
        iorai = IOpenRolesAdminInternal(_openRolesAdminInternalAddress);
        return true;
    }

    function setOpenRoles(address _openRolesAddress) external returns (bool _set){
        require(ior.isAllowed(dApp, openAdminRole, self, "setOpenRoles", msg.sender) ," Open Roles Derivative Types Admin : setOpenRoles : 00 : authorised roles only");
        ior = IOpenRoles(_openRolesAddress); 
        return true; 
    }

    //============================================= INTERNAL ==========================================
    
    function unmapRolesFromContractTypeInternal(string memory _contractType, string [] memory _roles) internal returns(bool _unmapped) {
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x]; 
            require(isKnownMappingByContractTypeByRole[role_][_contractType], string(" Open Roles Derivative Types Admin: unmapRolesFromContractTypeInternal : 00 : attempt to unmap unknown mapping ").append(role_).append(" : ").append(_contractType) );

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

    function removeFunctionsForRoleForDerivativeContactTypeInternal(string memory _contractType, string memory _role, string [] memory _functions) internal returns (bool _removed) { 
        require(isKnownMappingByContractTypeByRole[_role][_contractType], string(" Open Roles Derivative Types Admin : removeFunctionsForRoleForDerivativeContactTypeInternal : 00 : attempt to remove functions for unknown mapping : ").append(_contractType).append(" : ").append(_role));
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            functionsByDerivativeContractTypeByRole[_role][_contractType] = function_.remove(functionsByDerivativeContractTypeByRole[_role][_contractType]);
            isKnownFunctionByContractTypeByRole[_role][_contractType][function_] = false; 
        }
        return true; 
    }

    function initDefaultRoleConfiguration() internal returns (bool _configured){  

       hasDefaultFunctionsByRole[openAdminRole] = true; 
       defaultFunctionsByRole[openAdminRole].push("setOpenRolesAdminInternal");
       defaultFunctionsByRole[openAdminRole].push("setOpenRoles");
       
       hasDefaultFunctionsByRole[derivativeContractsAdminRole] = true; 
  
       defaultFunctionsByRole[derivativeContractsAdminRole].push("addDerivativeContractTypes");
       defaultFunctionsByRole[derivativeContractsAdminRole].push("removeDerivativeContractTypes");
       defaultFunctionsByRole[derivativeContractsAdminRole].push("mapRolesToContractType");
       defaultFunctionsByRole[derivativeContractsAdminRole].push("unmapRolesFromContractType");
       defaultFunctionsByRole[derivativeContractsAdminRole].push("addFunctionsForRoleForDerivativeContactType");
       defaultFunctionsByRole[derivativeContractsAdminRole].push("removeFunctionsForRoleForDerivativeContactType");
       return true; 
    }
}
