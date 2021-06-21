// SPDX-License-Identifier: APACHE 2.0
pragma solidity >0.8.0 <0.9.0; 

/**
 * @title IRoleManagerAdmin - Open Block Enterprise Initiative component
 * @author Block Star Logic
 * @dev This interface is to enable manual or tool-based management of a RoleManager instance. 
 */
interface IRoleManagerAdmin {
    
    /**
     * @dev this returns the role list names and barred list names that are currently in use across the RoleManager instance
     * @return _roleLists _barredLists
     */
    function getLists() external returns (string[] memory _roleLists, string[] memory _barredLists);
    
    /**
     * @dev this returns the role list names and barred list names which are associated with this '_address'
     * @return _roleLists _barredLists
     */
    function getListsForAddress(address _address) external returns (string [] memory _roleLists, string [] memory _barredLists);

    /**
     * @dev this will add the given '_address' to the give '_list'
     * @return _added 'true' if the address is added to the list
     */
    function addAddressToList( string memory _list, address _address) external returns (bool _added);

    /**
     * @dev this will remove the given '_address' from the given '_list'
     * @return _removed 'true' if the address is successfully removed from the list
     */
    function removeAddressFromList(string memory _list, address _address) external returns (bool _removed);

    /**
     * @dev this will add a new '_list' to the RoleManager instance and flag whether it's a barred list
     * @return _added 'true' if the list is successfully added
     */
    function addList(string memory _list, bool _isBarredList) external returns (bool _added);
    
    /**
     * @dev this will delete the '_list' from this RoleManager instance
     * @return _deleted 'true' if the list is successfully deleted
     */    
    function deleteList(string memory _list) external returns (bool _deleted);
    /**
     * @dev this will return the addresses that are on the '_list'
     * @return _addresses attached to the list
     */
    function getListAddresses(string memory _list) external returns (address [] memory _addresses);
    
}