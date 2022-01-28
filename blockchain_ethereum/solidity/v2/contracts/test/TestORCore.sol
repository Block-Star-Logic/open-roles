//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesDerivativeAdmin.sol";

import "./TestORDerivative.sol";

import "../interfaces/IOpenRolesManaged.sol";

contract TestORCore is IOpenRolesManaged { 

    
    address self; 
    IOpenRoles or; 
    string dApp = "TEST_DAPP"; 
    
    string role = "TEST_CORE_CONTRACT_ROLE";
    string admin = "TEST_ADMIN_ROLE"; 
    
    string derivativeContractType = "TEST_DERIVATIVE_CONTRACT_TYPE";
    
    address derivativeTest; 
    bool derivativeTestCreated;

    string name = "TEST_OR_CORE"; 
    uint256 version = 1; 

    // Open Roles Managed
    string [] roleNames; 
    mapping(string=>bool) hasDefaultFunctionsByRole; 
    mapping(string=>string[]) defaultFunctionsByRole; 

    constructor(address _openRoles) {       
        or = IOpenRoles(_openRoles);        
        self = address(this);  
        initDefaultRoleConfiguration();       
    }
    
    function getName() override view external returns(string memory _name) {
        return name; 
    }

    function getVersion () override view external returns (uint256 _version) { 
        return version; 
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

    function testAllowUser() view external returns (bool _userAllowed){
        return or.isAllowed(dApp,  role, self, "testAllowUser", msg.sender ); // user on list
    }

    function testDoNotAllowUser() view external returns (bool _userNOTAllowed){ // user not on list FALSE == FAIL 
        if(!or.isAllowed(dApp, role, self, "testDoNotAllowUser", msg.sender)){
            return true; 
        }
        return false; 
    }

    function testBarUser() view external returns (bool _userBarred){ // user on list
        return or.isBarred(dApp, role, self, "testBarUser", msg.sender);
    }

    function testDoNotBarUser() view external returns (bool _userNOTBarred){ // user not on list FALSE == FAIL 
        if(!or.isBarred(dApp,  role, self, "testDoNotBarUser", msg.sender)) {
            return true; 
        }
        return false;
    }

    function createDerivativeContractTest() external returns (address _derivativeContractTest){
        if(!derivativeTestCreated) {
            derivativeTest = address(new TestORDerivative(address(or)));
            configureDerivativeContract(derivativeTest);                        
            derivativeTestCreated = true; 
        }
        return derivativeTest;
    }

    function setOpenRoles(address _openRoles) external returns(bool _set){
        or.isAllowed(dApp, admin, self, "setOpenRoles", msg.sender );
        or = IOpenRoles(_openRoles); 
        return true; 
    }

    function getDerivativeContractTest() view external returns (address _d) {  
        return derivativeTest;
    }

    function configureDerivativeContract(address _derivativeContract) internal returns (bool _configured) {
        IOpenRolesDerivativesAdmin iorda = IOpenRolesDerivativesAdmin(or.getDerivativeContractsAdmin(dApp));
        iorda.addDerivativeContract(derivativeTest, derivativeContractType);
        
        string [] memory roles_ = new string[](3);
        roles_[0] = "TEST_DERIVATIVE_CONTRACT_ROLE";
        
        iorda.addRolesForDerivativeContract(_derivativeContract, roles_);

        string [] memory testRoleFunctions_     = new string[](2);
        testRoleFunctions_[0] = "testAllowUser";
        testRoleFunctions_[1] = "testBarUser";
      
        iorda.addFunctionsForRoleForDerivativeContract(_derivativeContract, roles_[0], testRoleFunctions_);

        address [] memory testLocalUsers = new address[](2);

        testLocalUsers[0] = 0x2d772fd99a602EDF24B3DEd3AB55Eea04319041d; 
        testLocalUsers[1] = 0xf3e47F5a7C0a69B71800c2341e9f50837Ed7965C; 

        iorda.addUsersForRoleForDerivativeContract(_derivativeContract, roles_[0], testLocalUsers);

        // all other users configured in Types Admin

        return true; 
    }

    function initDefaultRoleConfiguration() internal returns (bool _configured){
        roleNames = new string[](2);
        roleNames[0] = admin;
        roleNames[1] = role;

       string [] memory adminFunctions = new string[](1);
       adminFunctions[0] = "setOpenRoles";
  
       defaultFunctionsByRole[admin] = adminFunctions;
       hasDefaultFunctionsByRole[admin] = true; 

       string [] memory roleFunctions = new string[](2);
       roleFunctions[0] = "testAllowUser";
       roleFunctions[1] = "testBarUser";
   
       defaultFunctionsByRole[role] = roleFunctions; 
       hasDefaultFunctionsByRole[role] = true; 

       return true; 
    }


}
