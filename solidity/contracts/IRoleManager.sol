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
     * @dev This function returns whether 'msg.sender' is on the given 'role list'
     * @param _roleList list of allowed addresses configured on this implementation
     * @return _isAllowed 'true' if the role is on the list
     */
    function isAllowed(string memory _roleList) external view returns (bool _isAllowed);

    /**
     * @dev This function returns whether 'msg.sender is on a given 'barred list'
     * @param _barredList list of barred addresses configured on this implementation
     * @return _isBarred 'true'  if msg.sender is on the barred list
     */
    function isBarred(string memory _barredList) external view returns(bool _isBarred);
}