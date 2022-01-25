//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IOpenRoles.sol";


contract TestORDerivative { 

    IOpenRoles or; 
    address self; 

    string localRole = "TEST_ROLE";
    string dappRole  = "TEST_DAPP_ROLE"; // configured in Types Admin 
    string adminRole = "TEST_ADMIN_ROLE";

    constructor( address _openRoles){
        self = address(this);
        or = IOpenRoles(_openRoles);
    }

    // ====================== LOCAL LEVEL ROLE ONLY TESTS ===============================

    function testAllowUser() view external returns (bool _userAllowed){
        return or.isAllowed(self, localRole, "testAllowUser", msg.sender );
    }

    function testDoNotAllowUser() view external returns (bool _userAllowed){ // false
        return or.isAllowed(self, localRole, "testDoNotAllowUser", msg.sender);
    }

    function testBarUser() view external returns (bool _userBarred){
        return or.isBarred(self, localRole, "testBarUser", msg.sender);
    }

    function testDoNotBarUser() view external returns (bool _userBarred){ // false
        return or.isBarred(self, localRole, "testDoNotBarUser", msg.sender);
    }

    // ====================== LOCAL LEVEL ROLE @ DAPP LEVEL TESTS =========================
    
    function testAllowDappUserLocal() view external returns (bool _userAllowed){
        return or.isAllowed(self, localRole, "testAllowDappUser", msg.sender);
    }

    function testDoNotAllowDappUserLocal() view external returns (bool _userNOTAllowed){
        return !or.isAllowed(self, localRole, "testDoNotAllowDappUser", msg.sender);
    }

    function testBarDappUserLocal() view external returns (bool _userBarred){
        return or.isBarred(self, localRole, "testBarDappUser", msg.sender);
    }

    function testDoNotBarDappUserLocal() view external returns (bool _userNotBarred){
        return !or.isBarred(self, localRole, "testDoNotBarDappUser", msg.sender);
    }

    // ====================== DAPP LEVEL ONLY ROLE TESTS ==================================

    function testAllowDappUser() view external returns (bool _userAllowed){
        return or.isAllowed(self, dappRole, "testAllowDappUser", msg.sender);
    }

    function testDoNotAllowDappUser() view external returns (bool _userNOTAllowed){
        return !or.isAllowed(self, dappRole, "testDoNotAllowDappUser", msg.sender);
    }

    function testBarDappUser() view external returns (bool _userBarred){
        return or.isBarred(self, dappRole, "testBarDappUser", msg.sender);
    }

    function testDoNotBarDappUser() view external returns (bool _userNotBarred){
        return !or.isBarred(self, dappRole, "testDoNotBarDappUser", msg.sender);
    }

    // ====================== DAPP ADMIN ONLY ==============================================

    function setOpenRoles(address _openRoles) external returns(bool _set){
        or.isAllowed(self, adminRole, "setOpenRoles", msg.sender );
        or = IOpenRoles(_openRoles); 
        return true; 
    }

}