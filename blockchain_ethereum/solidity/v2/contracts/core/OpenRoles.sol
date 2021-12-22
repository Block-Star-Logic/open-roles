//"SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IOpenRoles.sol";
import "../interfaces/IOpenRolesEditor.sol";

contract OpenRoles is IOpenRoles, IOpenRolesEditor { 

   // role -> contract address -> function -> allowed
    mapping(string=>mapping(address=>mapping(string=>bool))) allowByRoleAddressFunction; 

    // contract address -> function -> role -> allowed
    mapping(address=>mapping(string=>mapping(string=>bool))) allowByaddressFunctionRole;

    // role -> user address -> has role 
    mapping(string=>mapping(address=>bool)) hasAddressByRole; 

    // user address -> role -> has role 
    mapping(address=>mapping(string=>bool)) hasRoleByAddress; // allow list

    // user address -> role -> contract address -> has role 
    mapping(address=>mapping(string=>mapping(address=>bool)))  hasRoleForAddressByUserAddress;

    // contract address -> user address -> role 
    mapping(address=>mapping(address=>string)) userRoleForAddress;

    // posting -> owner -> is owner
    mapping(address=>mapping(address=>bool)) postingOwnerByPosting; 

    // contract address -> user address -> is barred
    mapping(address=>mapping(address=>bool)) barredBySenderAddress;

    // contract address -> role -> user address -> is barred
    mapping(address=>mapping(string=>mapping(address=>bool))) barredByRoleSenderAddress;

    // contract address -> function -> role -> user address -> is barred
    mapping(address=>mapping(string=>mapping(string=>mapping(address=>bool)))) barredBySenderRoleFunctionAddress;

    mapping(address=>bool) bannedAddress; 

    mapping(address=>bool) isKnownAddress; 

    // dApp scope
    function isAllowed(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isAllowed){

    }

    function isBarred(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isBarred){

    }

    function getRolesForDapp(string memory _dApp) override view external returns (string [] memory _roleNames){

    }

    function getContractsForDapp(string memory _dApp) override view external returns (address [] memory _contacts, string [] memory _names){

    }
    
    function getUserAddressesForRoleForDapp(string memory _dApp, string memory _role) override view external returns (address [] memory _userAddresses){

    }

    function getContractsForRoleForDapp(string memory _dApp, string memory _role) override view external returns (address [] memory _contracts, string [] memory _names){

    }

    function getFunctionPermissionsForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract) override view external returns (string [] memory _functions, string [] memory _permision){

    }


    // contact scope 
    function isAllowed(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isAllowed){

    }

    function isBarred(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isBarred){

    }

    function getRolesForContract(address _contract) override view external returns (string [] memory _roleNames){

    }

    function getFunctionsForRoleforContract(address _contract, string memory _role) override view external returns (string [] memory _functions){

    }

    function getUserAddressesForRoleForContract(address _contract, string memory _role) override view external returns (address [] memory _userAddresses){
    }

    function getFunctionPermissionsForRoleForContract(address _contract, string memory _role) override view external returns (string [] memory _functions, string [] memory _permision){

    }

}
