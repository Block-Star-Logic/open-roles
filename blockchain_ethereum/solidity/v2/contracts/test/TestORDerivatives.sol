//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";


contract TestORDerivative { 

    IOpenRoles or; 
    address self; 

    string localRole = "TEST_DERIVATIVE_CONTRACT_ROLE";
    string dappRole  = "TEST_CORE_DAPP_ROLE"; // configured in Types Admin 
    string adminRole = "TEST_ADMIN_ROLE";

    constructor( address _openRoles){
        self = address(this);
        or = IOpenRoles(_openRoles);
    }

    // ====================== LOCAL LEVEL ROLE ONLY TESTS ===============================

    function testAllowUser() view external returns (bool _userAllowed){ // TEST ROLE user is on list
        return or.isAllowed(self, localRole, "testAllowUser", msg.sender );
    }

    function testDoNotAllowUser() view external returns (bool _userAllowed){ // TEST ROLE user is NOT on list  : false == FAIL
        if(!or.isAllowed(self, localRole, "testDoNotAllowUser", msg.sender)){
            return true; 
        }
        return false;
    }

    function testBarUser() view external returns (bool _userBarred){ // TEST ROLE user is on list
        return or.isBarred(self, localRole, "testBarUser", msg.sender);
    }

    function testDoNotBarUser() view external returns (bool _userBarred){ // TEST ROLE user is NOT on list : false == FAIL
        if(!or.isBarred(self, localRole, "testDoNotBarUser", msg.sender)) { 
            return true; 
        }
        return false;
    }

    // ====================== LOCAL LEVEL ROLE @ DAPP LEVEL TESTS =========================
    
    function testAllowDappUserLocal() view external returns (bool _userAllowed){ // TEST ROLE user is on list
        return or.isAllowed(self, localRole, "testAllowDappUserLocal", msg.sender);
    }

    function testDoNotAllowDappUserLocal() view external returns (bool _userNOTAllowed){ // TEST ROLE user is NOT on list : false == FAIL
        if(!or.isAllowed(self, localRole, "testDoNotAllowDappUserLocal", msg.sender)){ 
            return true; 
        }
        return false;
    }

    function testBarDappUserLocal() view external returns (bool _userBarred){ // TEST ROLE user is on list
        return or.isBarred(self, localRole, "testBarDappUserLocal", msg.sender);
    }

    function testDoNotBarDappUserLocal() view external returns (bool _userNotBarred){ // TEST ROLE user is NOT on list : false == FAIL
        if(!or.isBarred(self, localRole, "testDoNotBarDappUserLocal", msg.sender)){
            return true;
        }
        return false; 
    }

    // ====================== DAPP LEVEL ONLY ROLE TESTS ==================================

    function testAllowDappUser() view external returns (bool _userAllowed){  // TEST DAPP ROLE user is on list
        return or.isAllowed(self, dappRole, "testAllowDappUser", msg.sender);
    }

    function testDoNotAllowDappUser() view external returns (bool _userNOTAllowed){ // TEST DAPP user is NOT on list : false == FAIL 
        if(!or.isAllowed(self, dappRole, "testDoNotAllowDappUser", msg.sender)){
            return true;
        }
        return false;
    }

    function testBarDappUser() view external returns (bool _userBarred){ // TEST DAPP ROLE user is on list
        return or.isBarred(self, dappRole, "testBarDappUser", msg.sender);
    }

    function testDoNotBarDappUser() view external returns (bool _userNotBarred){ // TEST DAPP user is NOT on list : false == FAIL
        if(!or.isBarred(self, dappRole, "testDoNotBarDappUser", msg.sender)){
            return true; 
        }
        return false;
    }

    // ====================== DAPP ADMIN ONLY ==============================================

    function setOpenRoles(address _openRoles) external returns(bool _set){
        or.isAllowed(self, adminRole, "setOpenRoles", msg.sender );
        or = IOpenRoles(_openRoles); 
        return true; 
    }

}