//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-libraries/blob/main/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "../interfaces/IOpenRolesAdmin.sol";

import "../interfaces/IOpenRolesAdminInternal.sol";

import "../interfaces/IOpenRolesDerivativesAdmin.sol";

contract OpenRolesAdmin is IOpenVersion, IOpenRolesAdmin, IOpenRolesAdminInternal {

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    string name; 
    uint256 version = 6; 

    address rootAdmin; 
    address self;

    string [] dappList; 
    mapping(string=>bool) isKnownDappByDapp;

    mapping(string=>bool) derivativeContractAdminActiveByDApp; 
    mapping(string=>address) derivativeContractAdminAddressByDApp; 
    mapping(string=>address) derivativeContractTypesAdminAddressByDApp; 

   

    // roles
    mapping(string=>string[]) rolesByDapp; 

    mapping(string=>mapping(string=>bool)) isKnownRoleByDapp;

    // contracts
    mapping(string=>address[]) contractsByDapp; 

    mapping(address=>string[]) dappsByContract; 

    mapping(string=>mapping(address=>string)) contractNameByContractByDapp; 

    mapping(string=>mapping(address=>bool)) isKnownContractByDapp; 


    // mappings
    mapping(string=>mapping(string=>address[])) contractsByRoleByDapp; 
    mapping(string=>mapping(string=>mapping(address=>bool))) isKnownContractByRoleByDapp; 

    mapping(address=>mapping(string=>string[])) rolesByDappByContract;
    mapping(address=>mapping(string=>mapping(string=>bool))) isKnownRoleByDappByContract;
    
    mapping(string=>mapping(string=>mapping(address=>string[]))) functionsByContractByRoleByDapp; 
    mapping(string=>mapping(string=>mapping(address=>mapping(string=>bool)))) isKnownFunctionsByContractByRoleByDapp; 


    mapping(string=>mapping(string=>address[])) usersByRoleByDapp; 
    mapping(string=>mapping(string=>mapping(address=>bool))) isKnownUserByRoleByDapp; 

    constructor(string memory _name, address _rootAdmin) {
        name = _name; 
        rootAdmin = _rootAdmin; 
        self = address(this);
    }

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }

    function getDerivativeContractsAdmin(string memory _dApp) override view external returns (address _derivativeContractAdminAddress){ 
        return derivativeContractAdminAddressByDApp[_dApp];
    }

    function getDerivativeContractTypesAdmin(string memory _dApp) override view external returns (address _derivativeContractTypesAdminAddress){
        return derivativeContractTypesAdminAddressByDApp[_dApp];        
    }


    function getDappForDerivativeContract(address _contract) override view external returns (string memory _dApp)  {
       for(uint256 x = 0; x < dappList.length; x++){
          _dApp = dappList[x];
          if(derivativeContractAdminActiveByDApp[_dApp]){
            IOpenRolesDerivativesAdmin iorda = IOpenRolesDerivativesAdmin(derivativeContractAdminAddressByDApp[_dApp]);
            if(iorda.isRegistered(_contract)){
                return _dApp; 
            }
          }
       }
       return "UNKNOWN";
    }

    // listing function 
        // list dApps
    function listDapps() override view external returns (string [] memory _dappList){
        return dappList; 
    }

        // list dApp wide roles 
    function listRolesForDapp(string memory _dApp) override view external returns(string [] memory _dappRoleList){
        return rolesByDapp[_dApp];
    }

    function isKnownRoleByDappInternal(string memory _dapp, string memory _role) override view external returns (bool _isKnownRoleByDapp){
        return isKnownRoleByDapp[_dapp][_role];
    }

    function listUsersForRoleInternal(string memory _dApp, string memory _role) override view external returns (address[] memory _userAddresses){
        return usersByRoleByDapp[_dApp][_role];
    }

        // list core contracts in dApp
    function listContractsForDapp(string memory _dApp) override view external returns (string [] memory _contractNames, address [] memory _contracts){
        _contracts = contractsByDapp[_dApp];
        _contractNames = new string[](_contracts.length);
        for(uint256 x = 0; x < _contracts.length; x++){
            _contractNames[x] = contractNameByContractByDapp[_dApp][_contracts[x]];
        }
        return (_contractNames, _contracts); 
    }

        // list core contracts for role in dApp 
    function listContractsForRoleForDapp(string memory _dApp, string memory _role) override view external returns (string [] memory _contractNames, address[] memory _contractAddresses){
        _contractAddresses = contractsByRoleByDapp[_dApp][_role]; 
        _contractNames = new string[](_contractAddresses.length);
        for(uint256 x = 0; x < _contractAddresses.length; x++){
            _contractNames[x] = contractNameByContractByDapp[_dApp][_contractAddresses[x]];
        }
        return (_contractNames, _contractAddresses);
    }

        // list functions on ctontract for dApp wide role for dApp
    function listFunctionsForRoleForContractForDapp(string memory _dApp, string memory _role, address _contractAddress) override view external returns (string [] memory _functions){
        return functionsByContractByRoleByDapp[_dApp][_role][_contractAddress];
    } 

        // list user addreses assigned to dApp wide role 
    function listUsersForRole(string memory _dApp, string memory _role) override view external returns (address[] memory _userAddresses){
        return usersByRoleByDapp[_dApp][_role];
    }

    // entity functions 

        // dApp 
    function addDapp(string memory _dApp) override external returns (bool _added){
        doSecurity(msg.sender, "addDapp");
        if(!isKnownDappByDapp[_dApp]){
            dappList.push(_dApp);
            isKnownDappByDapp[_dApp]  = true;             
        }      
        return true;  
    }

    function removeDapp(string memory _dApp) override external returns (bool _removed){
        doSecurity(msg.sender, "removeDapp");
        
        // remove contracts first
        this.removeContractsForDapp(_dApp, contractsByDapp[_dApp]);
        delete contractsByDapp[_dApp];
        
        // then remove roles 
        this.removeRolesForDapp(_dApp, rolesByDapp[_dApp]);
        delete rolesByDapp[_dApp];
        
        // then remove dApp
        delete isKnownDappByDapp[_dApp];
        return true; 
    }
    
        // dApp wide roles
    function addRolesForDapp(string memory _dApp, string [] memory _roleNames) override external returns ( bool _added){
        doSecurity(msg.sender, "addRolesForDapp");
        for(uint256 x = 0; x < _roleNames.length; x++){
            string memory role_ = _roleNames[x];
            require(!isKnownRoleByDapp[_dApp][role_], string(" Open Roles Admin - addRoleseForDapp : 00 : - attempted to add known role : "). append(role_));
            rolesByDapp[_dApp].push(role_);
            isKnownRoleByDapp[_dApp][role_] = true;
        }
        return true; 
    }

    function removeRolesForDapp(string memory _dApp, string [] memory _roleNames) override external returns (bool _removed){
        doSecurity(msg.sender, "removeRolesForDapp");

        string [] memory roles_ = rolesByDapp[_dApp];        
        string [] memory remainingRoles_ = new string[](roles_.length - _roleNames.length);
        uint256 y = 0; 
        for(uint256 x = 0; x < roles_.length; x++){
            string memory role_ = roles_[x];
            if(role_.isContained(_roleNames)){
                address [] memory contractAddresses_ = contractsByRoleByDapp[_dApp][role_];

                for(uint256 z = 0; z < contractAddresses_.length; z++){
                    address contractAddress_ = contractAddresses_[z];
                    delete functionsByContractByRoleByDapp[_dApp][role_][contractAddress_];                
                }

                delete contractsByRoleByDapp[_dApp][role_];
                delete usersByRoleByDapp[_dApp][role_];
                delete isKnownRoleByDapp[_dApp][role_];
            }
            else {
                remainingRoles_[y] = role_;
                y++;
            }                        
        }
        rolesByDapp[_dApp] = remainingRoles_; 
        return true;         
    }

    
        // dApp core contracts
    function addContractsForDapp(string memory _dApp, address [] memory _contracts, string [] memory _contractNames) override external returns (bool _added){
        doSecurity(msg.sender, "addContractsForDapp");
        for(uint256 x = 0; x < _contracts.length; x++){
            address contractAddress_ =  _contracts[x]; 
            
            require(!isKnownContractByDapp[_dApp][contractAddress_], string(" Open Roles Admin : addContractsForDapp : 00 : - attempted to add dApp known contract : ").append(string(abi.encodePacked(contractAddress_)))); 

            contractsByDapp[_dApp].push(contractAddress_);
            contractNameByContractByDapp[_dApp][contractAddress_] = _contractNames[x];
            isKnownContractByDapp[_dApp][contractAddress_] = true; 

        }
        
        return true; 
    }

    function removeContractsForDapp(string memory _dApp, address [] memory _contractAddresses) override external returns (bool _removed){
        doSecurity(msg.sender, "removeContractsForDapp");
        
        address [] memory contractAddresses_ = contractsByDapp[_dApp]; 
        address [] memory remainingContractAddresses_ = new address[](contractAddresses_.length - _contractAddresses.length);
        uint256 x = 0; 
        for(uint256 y = 0; y < contractAddresses_.length; y++) {
            address contractAddress_ = contractAddresses_[y];
            if(contractAddress_.isContained(_contractAddresses)) {

                // @todo reverse mapping                
                string [] memory roles_ = rolesByDappByContract[contractAddress_][_dApp];
                address [] memory o_ = new address[](1);
                o_[1] = contractAddress_;
                for(uint256 z  = 0; z < roles_.length; z++){
                    string memory role_ = roles_[z];
                    this.removeContractsForRoleForDapp(_dApp, role_, o_);
                }

                delete contractNameByContractByDapp[_dApp][contractAddress_];                                
                delete isKnownContractByDapp[_dApp][contractAddress_];
            }
            else {
                remainingContractAddresses_[x] = contractAddress_; 
                x++;
            }                        
        }
        contractsByDapp[_dApp] = remainingContractAddresses_; 
        return true; 
    }    


    // mapping functions 

        // add users to dApp wide role 
    function addUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) override external returns (bool _added){
        doSecurity(msg.sender, "addUserAddressesForRoleForDapp");
        for(uint256 x = 0; x < _userAddresses.length; x++){
            address user_ = _userAddresses[x];
            require(!isKnownUserByRoleByDapp[_dApp][_role][user_], string(" Open Roles Admin : addUserAddressesForRoleForDapp : 00 : - attempted to add known user for role  for dApp : ").append(string(abi.encodePacked(user_))));
            usersByRoleByDapp[_dApp][_role].push(user_);
            isKnownUserByRoleByDapp[_dApp][_role][user_] = true; 
        }
        return true; 
    }

    function removeUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) override external returns (bool _removed){
        doSecurity(msg.sender, "removeUserAddressesForRoleForDapp");
        address [] memory users_ = usersByRoleByDapp[_dApp][_role]; 
        address [] memory remainingUsers_ = new address[](users_.length - _userAddresses.length);
        uint256 y = 0; 
        for(uint256 x = 0; x < users_.length; x++){
            address user_ = users_[x];
            if(user_.isContained(_userAddresses)) {
                isKnownUserByRoleByDapp[_dApp][_role][user_] = false; 
            }
            else {
                remainingUsers_[y] = user_;
                y++;
            }
        }
        usersByRoleByDapp[_dApp][_role] = remainingUsers_; 

        return true; 
    }

        // add core contracts for dApp wide role 
    function addContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) override external returns (bool _added){
        doSecurity(msg.sender, "addContractsForRoleForDapp");
        for(uint256 x = 0; x < _contracts.length; x++){
            address contract_ = _contracts[x];

            require(!isKnownContractByRoleByDapp[_dApp][_role][contract_], string(" Open Roles Admin : addContractsForRoleForDapp : 00 : - attempted to add known contract for role for dApp : ").append(string(abi.encodePacked(contract_))));

            contractsByRoleByDapp[_dApp][_role].push(contract_); 
            isKnownContractByRoleByDapp[_dApp][_role][contract_] = true;
            
            require(!isKnownRoleByDappByContract[contract_][_dApp][_role], string(" Open Roles Admin : addContractsForRoleForDapp : 01 : - attempted to add known role for contract  for dApp : ").append(_role).append(" : ").append(string(abi.encodePacked(contract_))));

            rolesByDappByContract[contract_][_dApp].push(_role);
            isKnownRoleByDappByContract[contract_][_dApp][_role] = true; 
        }

        return true; 
    }

    function removeContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) override external returns (bool _removed){
        doSecurity(msg.sender, "removeContractsForRoleForDapp");
        address [] memory contracts_ = contractsByRoleByDapp[_dApp][_role];
        address [] memory remainingContracts_ = new address[](contracts_.length - _contracts.length);
        uint256 y = 0; 
        for(uint256 x = 0; x < contracts_.length; x++){
            address contract_ = contracts_[x];
            if(contract_.isContained(_contracts)) {
                rolesByDappByContract[contract_][_dApp] = _role.remove(rolesByDappByContract[contract_][_dApp]);
                isKnownRoleByDappByContract[contract_][_dApp][_role] = false;

                isKnownContractByRoleByDapp[_dApp][_role][contract_] = false;
            }
            else { 
                remainingContracts_[y] = contract_; 
                y++;
            }
        }
        contractsByRoleByDapp[_dApp][_role] = remainingContracts_;
        return true; 
    }
    
        // add functions for contract for dApp wide role 
    function addFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) override external returns (bool _added){
        doSecurity(msg.sender, "addFunctionForRoleForContractForDapp");
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            require(!isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_], string(" Open Roles Admin : addFunctionForRoleForContractForDapp : 00 : - attempted to add known function for contract for role : ").append(function_).append(" : ").append(string(abi.encodePacked(_contract))).append(" : ").append(_role));
            functionsByContractByRoleByDapp[_dApp][_role][_contract].push(function_);
            isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_] = true; 
        }
        return true; 
    }

    function removeFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) override  external returns (bool _removed){
        doSecurity(msg.sender, "removeFunctionForRoleForContractForDapp");
        string[] memory functions_ = functionsByContractByRoleByDapp[_dApp][_role][_contract]; 
        string[] memory remainingFunctions_ = new string[](functions_.length - _functions.length);
        uint256 y = 0; 
        for(uint256 x = 0; x < functions_.length; x++){
            string memory function_ = functions_[x]; 
            if(function_.isContained(_functions)) { 
                isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_] = false; 
            }
            else { 
                remainingFunctions_[y] = function_; 
                y++; 
            }

        }
        return true; 
    }

    function addDerivativeContractManagementForDApp(address _derivativeContractAdmin, address _derivativeContractTypesAdmin, string memory _dApp) override external returns (bool _added){
        doSecurity(msg.sender, "addDerivativeContractManagementForDApp");
        if(!derivativeContractAdminActiveByDApp[_dApp]){
            derivativeContractAdminActiveByDApp[_dApp] = true; 
            derivativeContractAdminAddressByDApp[_dApp] = _derivativeContractAdmin;
            derivativeContractTypesAdminAddressByDApp[_dApp] = _derivativeContractTypesAdmin; 
        }
        return true; 
    }

    function removeDerivativeContractManagementForDApp( string memory _dApp) override external returns (bool _added){
        doSecurity(msg.sender, "removeDerivativeContractManagementForDApp");
        if(derivativeContractAdminActiveByDApp[_dApp]){
            derivativeContractAdminActiveByDApp[_dApp] = false; 
            delete derivativeContractAdminAddressByDApp[_dApp] ;
            delete derivativeContractTypesAdminAddressByDApp[_dApp]; 
        }
        return true; 
    }
   
    // ===========================================================


    function doSecurity(address _user, string memory _function) view internal returns (bool _done) {              
        require(_user == rootAdmin, string(" Open Roles Admin : ").append(_function).append(string(" 00 : - admin only")));                
        return true; 
    }

}