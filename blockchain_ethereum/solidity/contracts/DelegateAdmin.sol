// SPDX-License-Identifier: APACHE 2.0
pragma solidity >0.8.0 <0.9.0; 

import "./IDelegateAdmin.sol";
/**
 * @title DelegateAdmin - Open Block Enterprise Initiative component
 * @author Block Star Logic - Taurai Ushewokunze
 * @dev This is the 'standard' implementation of the IDelegateAdmin.sol interface. This implementation will enable delegated administration for 
 * a smart contract. 
 */
 
 contract DelegateAdmin is IDelegateAdmin {
     
    address private root; 
     
    address [] delegateAdminList; 
     
    mapping(address=>bool) delegateAdminStatusByAddress; 
    mapping(address=>uint256) daListIndexByAddress; 
     
    constructor(address _rootAddress) { 
        root = _rootAddress;    
    }

    function getRootAdmin() override external view returns (address _root){
        adminOnly();
        return root; 
    }
    
    function setRootAdmin(address _rootAddress) override external returns (bool _set){
        require(isRoot(), "sra 00 - root address only");
        root = _rootAddress;
        return true; 
    }
    
    function getDelegateAdmins() override external view returns (address [] memory _delegates){
        adminOnly();
        return delegateAdminList; 
    }
    
    function addDelegateAdmin(address _address) override external returns (bool _added){
        adminOnly();
        delegateAdminList.push(_address);
        delegateAdminStatusByAddress[_address] = true; 
        daListIndexByAddress[_address] = delegateAdminList.length; 
        return true; 
    }
    
    function removeDelegateAdmin(address _address) override external returns (bool _removed){
        adminOnly();
        delete delegateAdminStatusByAddress[_address]; 
        uint256 index = daListIndexByAddress[_address]-1;
        delete delegateAdminList[index];
        delete daListIndexByAddress[_address];
        return true; 
    }
    
    function isAdministratorOnly(address _caller) override external view returns(bool _isAdmin){
        return adminOnly(_caller);  
    }
    
    function adminOnly(address _caller) internal view returns (bool _isAdmin) {
        require(_caller == root || (delegateAdminStatusByAddress[_caller]), " ao 00 - admin address only ");
        return true; 
    }
    
    function adminOnly() internal view returns(bool _isAdmin) {
        require(isRoot() || (delegateAdminStatusByAddress[msg.sender]), "iao 00 - admin address only");
        return true; 
    }
    
    function isRoot() view internal returns ( bool _isRoot){
        return (msg.sender == root);
    }
     
 }