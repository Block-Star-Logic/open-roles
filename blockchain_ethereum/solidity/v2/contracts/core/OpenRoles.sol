//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;
 /**
  * 
  * @title Open Roles Core - Open Block Enterprise Initiative 
  * @author Block Star Logic
  * @dev This is the next iteration of Open Roles. This is the standard implementation that can be deployed into your contract network.  
  */
import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/main/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/main/blockchain_ethereum/solidity/v2/contracts/core/OpenRolesAdmin.sol"; 



contract OpenRoles is IOpenRoles, IOpenVersion { 

    uint version = 2;
    string name; 
    OpenRolesAdmin admin; 

    constructor(string memory _name, address _openRolesAdminAddress, string memory _pass) {
        name = _name; 
        admin = OpenRolesAdmin(_openRolesAdminAddress);
        admin.linkOpenRoles( address(this), _pass);
    }

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }


    // dApp scope
    function isAllowed(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isAllowed) {}

    function isBarred(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isBarred){}

    function getRolesForDapp(string memory _dApp) override view external returns (string [] memory _roleNames){}
    function getContractsForDapp(string memory _dApp) override view external returns (address [] memory _contacts, string [] memory _names){}
    
    function getUserAddressesForRoleForDapp(string memory _dApp, string memory _role) override view external returns (address [] memory _userAddresses){}

    function getContractsForRoleForDapp(string memory _dApp, string memory _role)override  view external returns (address [] memory _contracts, string [] memory _names){}

    function getFunctionPermissionsForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract) override view external returns (string [] memory _functions){}


    // contact scope 
    function isAllowed(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isAllowed){}

    function isBarred(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isBarred){}

    function getRolesForContract(address _contract) override view external returns (string [] memory _roleNames){}

    function getFunctionsForRoleforContract(address _contract, string memory _role) override view external returns (string [] memory _functions){}

    function getUserAddressesForRoleForContract(address _contract, string memory _role) override view external returns (address [] memory _userAddresses){}

    function getFunctionPermissionsForRoleForContract(address _contract, string memory _role) override view external returns (string [] memory _functions){}

            // derivative contracts 
    function addDerivativeContract(string memory _dApp, address _derivativeContractAddress, string memory _contractType) override external returns (bool _added){

    }

    function removeDerivativeContract(address _derivativeContractAddress) override external returns (bool _removed){

    }

        // roles for derivative contract
    function addRolesForDerivativeContract(address _derivativeContractAddress, string [] memory roles) override external returns (bool _added){

    }

    function removeRolesForDerivativeContract(address _derivativeContractAddress, string [] memory roles) override external returns (bool _removed){

    }

        // functions for derivative contract
    function addFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) override external returns (bool _added){

    }

    function removeFunctionsForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, string [] memory _functions) override external returns (bool _removed){

    }

        // users for derivative contract
    function addUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) override external returns (bool _added){
    
    }

    function removeUsersForRoleForDerivativeContract(address _derivativeContractAddress, string memory _role, address [] memory _users) override external returns (bool _removed){

    }

    // admin functions 
    function listDerivativeContractAddressesForContractTypeForDapp(string memory _dapp, string[] memory _contractType) view external returns (address [] memory _derivativeContractAddresses, string [] memory _derivativeContactTypes) {

    }

    function listDerivativeContractTypesForAddress(address _derivativeContractAddres) view external returns (string [] memory _derivativeContractTypes){ 

    }

    function getDapp(address _derivativeContractAddress) view external returns (string memory _dApp){

    }

    function getLocalUsers(address _derivativeContractAddress) view external returns (string [] memory _userAddresses) {

    }

}