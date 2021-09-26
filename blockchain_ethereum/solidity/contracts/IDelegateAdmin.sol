// SPDX-License-Identifier: APACHE 2.0
pragma solidity >0.8.0 <0.9.0; 

/**
 * @title IDelegateAdmin - Open Block Enterprise Initiative component
 * @author Block Star Logic
 * @dev This interface enables "public" delegated administration. This is typically to be used when administrative privileges need to be conferred to an address. 
 * 
 */
interface IDelegateAdmin { 
     /**
     * @dev this returns the 'root' admin that is usually set when initialising the instance
     * @return _root this returns the root address
     */
    function getRootAdmin() external returns (address _root);
     /**
     * @dev this sets the root admin 
     * @return _set 'true' if the admin is set
     */
    function setRootAdmin(address _root) external returns (bool _set);
     /**
     * @dev this returns the list of delegate admins for this instance. Delegate admins cannot remove the root admin
     * @return _delegates list of delegates
     */
    function getDelegateAdmins() external returns (address [] memory _delegates);
     /**
     * @dev this operation adds a delegate admin
     * @return _added 'true' if the delegate has been successfully added
     */
    function addDelegateAdmin(address _address) external returns (bool _added);
     /**
     * @dev this operation removes a delegate admin 
     * @return _removed 'true' if the delegate has been successfully removed
     */
    function removeDelegateAdmin(address _address) external returns (bool _removed);
     /**
     * @dev This operation is should be exposed to inside any calling contracts '_caller' is the address that needs to be checked
     * @return _isAdmin 'true' if the '_caller' is root or a 'delegate admin'
     */
    function isAdministratorOnly(address _caller) external returns(bool _isAdmin);
    
}