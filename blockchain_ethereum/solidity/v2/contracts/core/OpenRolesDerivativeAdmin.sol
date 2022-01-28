//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-libraries/blob/1d31958695b77852fbf1df545b69c3c3ebed8c8a/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesDerivativeAdmin.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";

import "../interfaces/IOpenRolesManaged.sol"; 

contract OpenRolesDerivativesAdmin is IOpenRolesManaged, IOpenRolesDerivativesAdmin { 

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 
    using LOpenUtilities for address[];

    string name;     
    uint256 version = 3; 
    address self; 

    string dApp; 
    IOpenRoles ior; 

    string sysAdminRole = "SYS_ADMIN_ROLE";
    string drivativesAdminRole = "DERIVATIVE_CONTRACTS_ADMIN_ROLE";

    // Open Roles Managed
    string [] roleNames; 
    mapping(string=>bool) hasDefaultFunctionsByRole; 
    mapping(string=>string[]) defaultFunctionsByRole; 

    // Derivative contracts; 
    address [] derivativeContracts; 

    mapping(address=>bool) registeredByDerivativeContract; 
    mapping(address=>string) derivativeContractTypeByDerivativeContract; 

    mapping(string=>address[]) derivativeContractsByDerivativeContractType; 
    mapping(address=>mapping(string=>bool)) knownByDerivativeContractTypeByDerivativeContract;

    mapping(string=>address[]) derivativeContractsByRole; 

    mapping(address=>string[]) rolesByDerivativeContract; 
    mapping(address=>mapping(string=>bool)) knownByRoleByDerivativeContract;

    mapping(string=>mapping(string=>mapping(address=>bool))) knownByDerivativeContractByDerivativeContractTypeByRole;
    mapping(string=>mapping(string=>address[])) derivativeContractsByContractTypeByRole; 
    
    mapping(string=>string[]) derivativeContractTypeByRole; 
    mapping(string=>mapping(string=>bool)) knownByDerivativeContractTypeByRole;

    mapping(address=>mapping(string=>mapping(string=>bool))) knownByFunctionByRoleByDerivativeContract; 
    mapping(address=>mapping(string=>string[])) functionsByRoleByDerivativeContract; 

    mapping(address=>mapping(string=>mapping(address=>bool))) knownByUserByRoleByDerivativeContract; 
    mapping(address=>mapping(string=>address[])) userAddressesByRoleByDerivativeContract; 

    mapping(address=>address[]) localContractUsersByDerivativeContract; 
    mapping(address=>mapping(address=>bool)) knownByUserByDerivativeContract; 


    constructor(string memory _name, string memory _dApp, address _openRolesAddress ) { 
        self = address(this);
        name = _name;         
        dApp = _dApp; 
        ior = IOpenRoles(_openRolesAddress); //@todo implement root security protocol    
        initDefaultRoleConfiguration();     
    }

    function getName() override view external returns (string memory _name){
        return name; 
    }

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getDApp() override view external returns (string memory _dApp) {
        return dApp; 
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


    function getRolesForContract(address _derivativeContract) override view external returns (string [] memory _roleNames){
        return rolesByDerivativeContract[_derivativeContract];
    }

    function getFunctionsForRoleforContract(address _derivativeContract, string memory _role) override view external returns (string [] memory _functions){
        return functionsByRoleByDerivativeContract[_derivativeContract][_role];
    }   

    function getUserAddressesForRoleForContract(address _derivativeContract, string memory _role) override view external returns (address [] memory _userAddresses){
        return userAddressesByRoleByDerivativeContract[_derivativeContract][_role];
    }

    function getLocalUsers(address _derivativeContract) override view external returns (address [] memory _userAddresses) {
        return localContractUsersByDerivativeContract[_derivativeContract]; 
    }

    function getDerivativeContractType(address _derivativeContract) override view external returns (string memory _derivativeContractTypes){
        return derivativeContractTypeByDerivativeContract[_derivativeContract];
    }

    function isRegistered( address _derivativeContract ) override view external returns (bool _isRegistered) { 
        return registeredByDerivativeContract[_derivativeContract]; 
    }

    function listDerivativeContracts() override view external returns( address [] memory _derivativeContracts,  string [] memory _derivativeContractTypes){
       return listContractsInternal(derivativeContracts);
    }
    
    function listDerivativeContractsForContractType(string memory _derivativeContractType) override view external returns (address [] memory _derivativeContracts){
       return derivativeContractsByDerivativeContractType[_derivativeContractType];
    }

    function listDerivativeContractTypesForRole(string memory _role) override view external returns (string [] memory _derivativeContractTypes){
        return derivativeContractTypeByRole[_role];
    }

    function listDerivativeContractsForRole(string memory _role) override view external returns (address [] memory _derivativeContracts, string [] memory _derivativeContractTypes){        
        return listContractsInternal(derivativeContractsByRole[_role]);
    }

    function listDerivativeContractsForRoleForContractType(string memory _role, string memory _contractType ) override view external returns (address [] memory _derivativeContracts){
        return derivativeContractsByContractTypeByRole[_role][_contractType];
    }

            // derivative contracts 
    function addDerivativeContract(address _derivativeContract, string memory _contractType) override external returns (bool _added){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "addDerivativeContract", msg.sender)," Open Roles Derivative Admin : addDerivativeContract : 00 : authorised roles only ");
        if(!registeredByDerivativeContract[_derivativeContract] ){
            derivativeContractTypeByDerivativeContract[_derivativeContract] = _contractType;
            knownByDerivativeContractTypeByDerivativeContract[_derivativeContract][_contractType] = true; 
            derivativeContractsByDerivativeContractType[_contractType].push(_derivativeContract);
            registeredByDerivativeContract[_derivativeContract] = true; 
            return true; 
        }      
        return false; 
    }

    function removeDerivativeContract(address _derivativeContract) override external returns (bool _removed){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "removeDerivativeContract", msg.sender)," Open Roles Derivative Admin : removeDerivativeContract : 00 : authorised roles only ");
        if(registeredByDerivativeContract[_derivativeContract] ){
            string memory contractType_ = derivativeContractTypeByDerivativeContract[_derivativeContract];

            delete derivativeContractTypeByDerivativeContract[_derivativeContract];
            
            knownByDerivativeContractTypeByDerivativeContract[_derivativeContract][contractType_] = false; 

            derivativeContractsByDerivativeContractType[contractType_] = _derivativeContract.remove(derivativeContractsByDerivativeContractType[contractType_]);
            registeredByDerivativeContract[_derivativeContract] = false; 
            return true; 
        }      
        return false; 
    }

        // roles for derivative contract
    function addRolesForDerivativeContract(address _derivativeContract, string [] memory roles) override external returns (bool _added){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "addRolesForDerivativeContract", msg.sender)," Open Roles Derivative Admin : addRolesForDerivativeContract : 00 : authorised roles only ");        
        for(uint256 x = 0; x < roles.length; x++){
            string memory role_ = roles[x]; 
            if(!knownByRoleByDerivativeContract[_derivativeContract][role_]){
                rolesByDerivativeContract[_derivativeContract].push(role_);                
                derivativeContractsByRole[role_].push(_derivativeContract);
            
                string memory contractType_ = derivativeContractTypeByDerivativeContract[_derivativeContract]; 
                require(knownByDerivativeContractTypeByDerivativeContract[_derivativeContract][contractType_], " Open Roles Derivative Admin : addRolesForDerivativeContract : 01 - contract type not specified. Likely NOT registered." );

                if(!knownByDerivativeContractTypeByRole[role_][contractType_]){
                    derivativeContractTypeByRole[role_].push(contractType_); 
                    knownByDerivativeContractTypeByRole[role_][contractType_] = true; 
                }
                if(!knownByDerivativeContractByDerivativeContractTypeByRole[role_][contractType_][_derivativeContract]){
                    derivativeContractsByContractTypeByRole[role_][contractType_].push(_derivativeContract);
                    knownByDerivativeContractByDerivativeContractTypeByRole[role_][contractType_][_derivativeContract] = true;                 
                }
                knownByRoleByDerivativeContract[_derivativeContract][role_] = true; 
            }
        }
        return true; 
    }

    function removeRolesForDerivativeContract(address _derivativeContract, string [] memory roles) override external returns (bool _removed){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "removeRolesForDerivativeContract", msg.sender)," Open Roles Derivative Admin : removeRolesForDerivativeContract : 00 : authorised roles only ");
        for(uint256 x = 0; x < roles.length; x++){
            string memory role_ = roles[x]; 
            if(knownByRoleByDerivativeContract[_derivativeContract][role_]){
                rolesByDerivativeContract[_derivativeContract] = role_.remove(rolesByDerivativeContract[_derivativeContract]);                
                derivativeContractsByRole[role_] = _derivativeContract.remove(derivativeContractsByRole[role_]);
            
                string memory contractType_ = derivativeContractTypeByDerivativeContract[_derivativeContract]; 
                require(knownByDerivativeContractTypeByDerivativeContract[_derivativeContract][contractType_], " Open Roles Derivative Admin : removeRolesForDerivativeContract : 01 : contract type not specified. Likely NOT registered." );

                if(knownByDerivativeContractTypeByRole[role_][contractType_]){
                    derivativeContractTypeByRole[role_] = contractType_.remove(derivativeContractTypeByRole[role_]);
                    knownByDerivativeContractTypeByRole[role_][contractType_] = false; 
                }
                if(knownByDerivativeContractByDerivativeContractTypeByRole[role_][contractType_][_derivativeContract]){
                    derivativeContractsByContractTypeByRole[role_][contractType_] = _derivativeContract.remove(derivativeContractsByContractTypeByRole[role_][contractType_]);
                    knownByDerivativeContractByDerivativeContractTypeByRole[role_][contractType_][_derivativeContract] = false;                 
                }
                knownByRoleByDerivativeContract[_derivativeContract][role_] = false; 
            }
        }
        return true; 
    }

        // functions for derivative contract
    function addFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) override external returns (bool _added){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "addFunctionsForRoleForDerivativeContract", msg.sender)," Open Roles Derivative Admin : addFunctionsForRoleForDerivativeContract : 00 : authorised roles only ");
        for(uint256 x = 0; x < _functions.length; x++) {
            string memory function_ = _functions[x];
            if(!knownByFunctionByRoleByDerivativeContract[_derivativeContractAddress][_role][function_]){
                functionsByRoleByDerivativeContract[_derivativeContractAddress][_role].push(function_);
                knownByFunctionByRoleByDerivativeContract[_derivativeContractAddress][_role][function_] = true;         
            }        
        }
        return true; 
    }

    function removeFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) override external returns (bool _removed){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "removeFunctionsForRoleForDerivativeContract", msg.sender)," Open Roles Derivative Admin : removeFunctionsForRoleForDerivativeContract : 00 : authorised roles only ");
        for(uint256 x = 0; x < _functions.length; x++) {
            string memory function_ = _functions[x];
            if(knownByFunctionByRoleByDerivativeContract[_derivativeContractAddress][_role][function_]){
                functionsByRoleByDerivativeContract[_derivativeContractAddress][_role] = function_.remove(functionsByRoleByDerivativeContract[_derivativeContractAddress][_role]);
                knownByFunctionByRoleByDerivativeContract[_derivativeContractAddress][_role][function_] = false;         
            }        
        }
        return true; 
    }

        // users for derivative contract
    function addUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) override external returns (bool _added){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "addUsersForRoleForDerivativeContract", msg.sender)," Open Roles Derivative Admin : addUsersForRoleForDerivativeContract : 00 : authorised roles only ");
        for(uint256 x = 0; x < _users.length; x++){
            address user_ = _users[x];
            if(!knownByUserByRoleByDerivativeContract[_derivativeContractAddress][_role][user_]){                
                userAddressesByRoleByDerivativeContract[_derivativeContractAddress][_role].push(user_);
                knownByUserByRoleByDerivativeContract[_derivativeContractAddress][_role][user_] = true; 
            }
            if(!knownByUserByDerivativeContract[_derivativeContractAddress][user_]){
                localContractUsersByDerivativeContract[_derivativeContractAddress].push(user_);
                knownByUserByDerivativeContract[_derivativeContractAddress][user_] = true; 
            }
        }
        return  true; 
    }

    function removeUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) override external returns (bool _removed){
        require(ior.isAllowed(dApp, drivativesAdminRole, self, "removeUsersForRoleForDerivativeContract", msg.sender)," Open Roles Derivative Admin : removeUsersForRoleForDerivativeContract : 00 : authorised roles only ");
        for(uint256 x = 0; x < _users.length; x++){
            address user_ = _users[x];
            if(knownByUserByRoleByDerivativeContract[_derivativeContractAddress][_role][user_]){                
                userAddressesByRoleByDerivativeContract[_derivativeContractAddress][_role] = user_.remove(userAddressesByRoleByDerivativeContract[_derivativeContractAddress][_role]);
                knownByUserByRoleByDerivativeContract[_derivativeContractAddress][_role][user_] = false; 
            }
            if(knownByUserByDerivativeContract[_derivativeContractAddress][user_]){
                localContractUsersByDerivativeContract[_derivativeContractAddress] = user_.remove(localContractUsersByDerivativeContract[_derivativeContractAddress]);
                knownByUserByDerivativeContract[_derivativeContractAddress][user_] = false; 
            }
        }
        return  true;   
    }

    function setOpenRoles(address _openRolesAddress) external returns (bool _set){
        require(ior.isAllowed(dApp, sysAdminRole, self, "setOpenRoles", msg.sender)," Open Roles Derivative Admin : setOpenRoles : 00 : authorised roles only ");
        ior = IOpenRoles(_openRolesAddress); 
        return true; 
    }

// =================================

    function initDefaultRoleConfiguration() internal returns (bool _configured){
        roleNames = new string[](2);
        roleNames[0] = sysAdminRole;
        roleNames[1] = drivativesAdminRole;

       string [] memory sysAdminFunctions = new string[](1);
       sysAdminFunctions[0] = "setOpenRoles";
       defaultFunctionsByRole[sysAdminRole] = sysAdminFunctions;
       hasDefaultFunctionsByRole[sysAdminRole] = true; 

       string [] memory derivativeAdminFunctions = new string[](8);
       derivativeAdminFunctions[0] = "addDerivativeContract";
       derivativeAdminFunctions[1] = "removeDerivativeContract";
       derivativeAdminFunctions[2] = "addRolesForDerivativeContract";
       derivativeAdminFunctions[3] = "removeRolesForDerivativeContract";
       derivativeAdminFunctions[4] = "addFunctionsForRoleForDerivativeContract";
       derivativeAdminFunctions[5] = "removeFunctionsForRoleForDerivativeContract";
       derivativeAdminFunctions[6] = "addUsersForRoleForDerivativeContract";
       derivativeAdminFunctions[7] = "removeUsersForRoleForDerivativeContract";
  
       defaultFunctionsByRole[drivativesAdminRole] = derivativeAdminFunctions; 

       hasDefaultFunctionsByRole[drivativesAdminRole] = true; 

       return true; 
    }

    function listContractsInternal(address[] memory _derivativeContracts) view internal returns (address[] memory _derivativeContractAddresses, string [] memory _derivativeContractTypes){
        _derivativeContractTypes = new string[](_derivativeContracts.length);
        for(uint256 x = 0; x < _derivativeContracts.length; x++){
            _derivativeContractTypes[x] = derivativeContractTypeByDerivativeContract[_derivativeContracts[x]];
        }
        return (_derivativeContracts, _derivativeContractTypes);
    }

}