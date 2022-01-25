//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IOpenRoles.sol";
import "../interfaces/IOpenRolesDerivativesAdmin.sol";

import "./TestORDerivative.sol";

contract TestORCore { 

    
    address self; 
    IOpenRoles or; 
    string dApp = "TEST_DAPP"; 
    string role = "TEST_CORE_DAPP_USER";
    string admin = "TEST_ADMIN_ROLE"; 
    string derivativeContractType = "TEST_DERIVATIVE_CONTRACT_TYPE";
    address derivativeTest; 
    bool derivativeTestCreated;

    constructor(address _openRoles) {
       
        or = IOpenRoles(_openRoles);        
        self = address(this);
        
    }
    
    function testAllowUser() view external returns (bool _userAllowed){
        return or.isAllowed(dApp,  role, self, "testAllowUser", msg.sender ); // user on llist
    }

    function testDoNotAllowUser() view external returns (bool _userNOTAllowed){
        return !or.isAllowed(dApp, role, self, "testDoNotAllowUser", msg.sender);
    }

    function testBarUser() view external returns (bool _userBarred){
        return or.isBarred(dApp, role, self, "testBarUser", msg.sender);
    }

    function testDoNotBarUser() view external returns (bool _userNOTBarred){
        return !or.isBarred(dApp,  role, self, "testDoNotBarUser", msg.sender);
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
        roles_[0] = "TEST_ROLE";
        
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


}
