//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.15;

 /**
  * 
  * @title Open Roles Core - Open Block Enterprise Initiative 
  * @author Block Star Logic
  * @dev This is the next iteration of Open Roles. This is the standard implementation that can be deployed into your contract network.  
  */
import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "https://github.com/Block-Star-Logic/open-libraries/blob/main/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "../interfaces/IOpenRolesAdmin.sol";

import "../interfaces/IOpenRolesAdminInternal.sol"; 

import "../interfaces/IOpenRolesDerivativesAdmin.sol";

import "../interfaces/IOpenRolesDerivativeTypesAdmin.sol";

import "../interfaces/IOpenRoles.sol";


contract OpenRoles is IOpenRoles, IOpenVersion { 

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    uint version = 10;

    string name = "RESERVED_OPEN_ROLES_CORE"; 

    IOpenRolesAdmin admin; 
    
    constructor(address _openRolesAdminAddress) {        
        admin = IOpenRolesAdmin(_openRolesAdminAddress);
    }

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }

    // dApp scope
    function isAllowed(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isAllowed) {
        return isOnDAppList(_dApp, _role, _contract, _function, _srcSender);
    }

    function isBarred(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) override view external returns (bool _isBarred){
        return isOnDAppList(_dApp, _role, _contract, _function, _srcSender);
    }

    // derivative contract scope 
    function isAllowed(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isAllowed){
        return isOnList(_contract, _role, _function, _srcSender, false);
    }

    function isBarred(address _contract, string memory _role, string memory _function, address _srcSender ) override view external returns (bool _isBarred){
        return isOnList(_contract, _role, _function, _srcSender, true);
    }

    function getDerivativeContractsAdmin(string memory _dApp) override view  external returns (address _address) {
        return admin.getDerivativeContractsAdmin(_dApp); 
    }

    // ==================================== INTERNAL =======================

    function isOnList(address _contract, string memory _role, string memory _function, address _srcSender, bool barring) view internal returns (bool _isOnList) {
        string memory dApp_ = admin.getDappForDerivativeContract(_contract); 
        if(!dApp_.isEqual("UNKNOWN")){
            IOpenRolesDerivativeTypesAdmin iordta = IOpenRolesDerivativeTypesAdmin(admin.getDerivativeContractTypesAdmin(dApp_));
            IOpenRolesDerivativesAdmin iorda = IOpenRolesDerivativesAdmin(admin.getDerivativeContractsAdmin(dApp_));

            string [] memory localRoles_ = iorda.getRolesForContract(_contract);
            if(_role.isContained(localRoles_)){

                address[] memory localUserAddresses_ = iorda.getUserAddressesForRoleForContract(_contract, _role);        
            
                if(_srcSender.isContained(localUserAddresses_)){
                    string [] memory functions_ = iorda.getFunctionsForRoleforContract(_contract,_role);
                    if(_function.isContained(functions_)){
                        return true; 
                    }
                    return false; 
                }
                return false; 
            }
            else { 
                string memory derivativeContractType_ = iorda.getDerivativeContractType(_contract); 
                string [] memory dappRoles_ = admin.listRolesForDapp(dApp_);
                if(_role.isContained(dappRoles_)){
                    address [] memory dappUserAddresses_ = iordta.listUsersForRoleForDerivativeContractType(derivativeContractType_, _role);
                    if(_srcSender.isContained(dappUserAddresses_)){
                        string [] memory functions_ = iordta.listFunctionsForRoleForDerivativeContractType(derivativeContractType_,_role);
                        if(_function.isContained(functions_)){
                            return true; 
                        }
                        return false;
                    }
                    return false;                    
                }
                return false; 
            }
           
        }
        else{
            if(barring) {
                return true; 
            }
        }
        return  false;
    }

    function isOnDAppList(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender) view internal returns (bool _isOnList) {
        address [] memory userAddresses_ = admin.listUsersForRole(_dApp, _role);
        if(_srcSender.isContained(userAddresses_)) {
            string [] memory functions_ = admin.listFunctionsForRoleForContractForDapp(_dApp, _role, _contract);
            if(_function.isContained(functions_)){
                return true; 
            }
        }
        return false;  
    }
}