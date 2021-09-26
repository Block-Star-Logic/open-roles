// SPDX-License-Identifier: APACHE 2.0
pragma solidity >0.7.0 <0.9.0; 

import "./IRoleManager.sol";
import "./IRoleManagerAdmin.sol";
import "./IDelegateAdmin.sol";
/**
 * @title RoleManager - Open Block Enterprise Initiative component
 * @author Block Star Logic - Taurai Ushewokunze
 * @dev This is the 'standard' implementation of the IRoleManager.sol and IRoleManagerAdmin.sol interfaces. 
 */

contract RoleManager is IRoleManager, IRoleManagerAdmin { 
    
    IDelegateAdmin delegateAdmin; 
    
    // roles 
    string [] roleLists; 
    string [] barredLists;
    
    mapping(string=>uint256) roleListIndexByRoleList; 
    mapping(string=>uint256) barredListIndexByBarredList; 
    
    mapping(string=>bool) knownListStatusByList; 
    mapping(string=>string) knownListTypeByList; 
    
    // addresses - Roles  
    mapping(string=>mapping(address=>bool))addressKnownStatusByAddressByRoleList;
    mapping(string=>mapping(address=>bool))addressBarredStatusByAddressByRoleList; 
   
    
    mapping(string=>address[]) roleListAddressesByRoleList; 
    mapping(string=>mapping(address=>uint256)) roleListAddressIndexByRoleList; 
    
    mapping(string=>address[]) barredListAddressesByBarredList; 
    mapping(string=>mapping(address=>uint256)) barredListAddressIndexByBarredList; 


    mapping(address=>string[]) roleListsByAddress;
    mapping(address=>mapping(string=>uint256)) roleListIndexByRoleListByAddress; 
    
    mapping(address=>string[]) barredListsByAddress; 
    mapping(address=>mapping(string=>uint256)) barredListIndexByRoleListByAddress; 
    
    mapping(address=>mapping(string=>uint256)) roleListForAddressIndexByAddress; 
    
    
    constructor(address delegateAdminAddress) {
        delegateAdmin = IDelegateAdmin(delegateAdminAddress);
    }
 
    function isAllowed(string memory _roleList) override external view returns (bool _isAllowed){
        return addressKnownStatusByAddressByRoleList[_roleList][msg.sender];   
    }

    function isBarred(string memory _barredList) override external view returns(bool _isBarred){
        return addressBarredStatusByAddressByRoleList[_barredList][msg.sender];
    }

    function getLists() override external returns (string[] memory _roleLists, string[] memory _barredLists){
        delegateAdmin.isAdministratorOnly(msg.sender);
        return (roleLists, barredLists); 
    }
    
    function getListsForAddress(address _address) override external returns (string [] memory _roleLists, string [] memory _barredLists){
        delegateAdmin.isAdministratorOnly(msg.sender);
        return (roleListsByAddress[_address], barredListsByAddress[_address]);
    }
    
    
    function addAddressToList( string memory _list, address _address) override external returns (bool _added){
        delegateAdmin.isAdministratorOnly(msg.sender);
        if(isEqual("BARRED",knownListTypeByList[_list] )){
            barredListAddressesByBarredList[_list].push(_address);
            uint256 index = barredListAddressesByBarredList[_list].length;
            barredListAddressIndexByBarredList[_list][_address] = index; 
            
            
            barredListsByAddress[_address].push(_list);
            index = barredListsByAddress[_address].length;
            barredListIndexByRoleListByAddress[_address][_list] = index; 
        }
        else {
            roleListAddressesByRoleList[_list].push(_address);
            uint256 index = roleListAddressesByRoleList[_list].length; 
            roleListAddressIndexByRoleList[_list][_address] = index;
            
            roleListsByAddress[_address].push(_list);
            index = roleListsByAddress[_address].length;
            roleListIndexByRoleListByAddress[_address][_list] = index;
            
            
        }
        return true; 
    }
    
    function removeAddressFromList( string memory _list, address _address) override external returns (bool _removed){
        delegateAdmin.isAdministratorOnly(msg.sender);
        if(isEqual("BARRED",knownListTypeByList[_list] )){
            uint256 index = barredListAddressIndexByBarredList[_list][_address];
            delete barredListAddressesByBarredList[_list][index];
            delete barredListAddressIndexByBarredList[_list][_address];
            
            index = barredListIndexByRoleListByAddress[_address][_list]; 
            delete barredListsByAddress[_address][index];
            delete barredListIndexByRoleListByAddress[_address][_list]; 
        }
        else {
            uint256 index = roleListAddressIndexByRoleList[_list][_address];
            delete roleListAddressesByRoleList[_list][index];
            delete roleListAddressIndexByRoleList[_list][_address];
            
            index = roleListIndexByRoleListByAddress[_address][_list];
            delete roleListsByAddress[_address][index];
            delete roleListIndexByRoleListByAddress[_address][_list];
        }
        
        return true; 
    }

    function addList(string memory _list, bool _isBarredList) override external returns (bool _added){
        delegateAdmin.isAdministratorOnly(msg.sender);
        require(!knownListStatusByList[_list], "arl 00 - known role."); // make sure we don't know this list already
        
        uint256 index; 
        if(_isBarredList){
            barredLists.push(_list);
            index = barredLists.length; 
            barredListIndexByBarredList[_list] = index; 
            knownListTypeByList[_list] = "BARRED";
        }
        else {
            roleLists.push(_list); 
            index = roleLists.length; 
            roleListIndexByRoleList[_list] = index; 
            knownListTypeByList[_list] = "ROLE";
        }
        knownListStatusByList[_list] = true; // now we know this list
        return true; 
    }
    
    function deleteList(string memory _list) override external returns (bool _deleted){
        delegateAdmin.isAdministratorOnly(msg.sender);
        require(knownListStatusByList[_list], "drl 00 - unknown list.");
        
        if(isEqual("BARRED",knownListTypeByList[_list] )){
            require(barredListAddressesByBarredList[_list].length == 0, " dl 00 barred list not empty. ");
            uint256 index = barredListIndexByBarredList[_list];
            delete barredLists[index];
            delete barredListIndexByBarredList[_list];
             
        }
        else {
            require(roleListAddressesByRoleList[_list].length == 0, " dl 01 role list not empty. ");
            uint256 index = barredListIndexByBarredList[_list];
            delete roleLists[index];
            delete barredListIndexByBarredList[_list];
            
        }
        delete knownListStatusByList[_list];
        delete knownListTypeByList[_list];
        return true; 
    }

    function getListAddresses(string memory _list) override external returns (address [] memory _addresses){
        delegateAdmin.isAdministratorOnly(msg.sender);
        require(knownListStatusByList[_list], "gla 00 - unknown list.");
        
        
        if(isEqual("BARRED",knownListTypeByList[_list] )){
            return barredListAddressesByBarredList[_list];     
        }
        else {
            return roleListAddressesByRoleList[_list];
        }
        
    }

    function addressToString(address _address) internal pure returns (string memory _stringAddress){
        return string(abi.encodePacked(_address));
    }
   
    function concat(string memory a, string memory b) internal pure returns (string memory _concatenated) {
        return string(abi.encodePacked(a, b));
    }
   
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
      return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }   
}