// SPDX-License-Identifier: APACHE 2.0
pragma solidity >=0.8.0 <0.9.0;

import "./OpenRolesSecure.sol";

contract OpenRolesSecureDerivative is OpenRolesSecure {

    constructor(){
    }

    function isSecure(string memory _role, string memory _function) override view internal returns (bool) {
        if(roleSecurityActive){
            return roleManager.isAllowed(self, _role, _function, msg.sender);
        }
       return true; 
    }
        
    function isSecureBarring(string memory _role, string memory _function) override view internal returns (bool) {       
       if(roleSecurityActive){
            if(roleManager.isBarred(self, _role, _function, msg.sender)){
                return false; 
            }
       }
       return true; 
    }

}