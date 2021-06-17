// SPDX-License-Identifier: APACHE 2.0
pragma solidity >0.8.0 <0.9.0; 

/**
 * @title Role Manager - Open Block Enterprise Initiative component
 * @author Block Star Logic
 * @dev This is the Role Manager interface. This is executed  by a smart contract to enact Role Based Security on Smart Contract Operations. 
 * The caller should have an address instance of RoleManager
 * 
 */
interface IRoleManager { 
    
    /**
     * @dev This function limits code execution of the 'msg.sender' to the addresses associated with the given '_roleList'
     * if the 'msg.sender' is not on the list the operation will 'revert'
     * @return _isAllowed 'true' always
     */
    function isAllowed(string memory _roleList) external view returns (bool _isAllowed);

      /**
     * @dev This function bars the execution of the code that follows if 'msg.sender' is on the associated _barredList
     * if 'msg.sender' is on the list the operation will 'revert'
     * @return _isBarred 'false' always
     */
    function isBarred(string memory _barredList) external view returns(bool _isBarred);
}