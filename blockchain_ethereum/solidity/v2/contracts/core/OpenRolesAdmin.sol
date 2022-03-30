//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-libraries/blob/703b21257790c56a61cd0f3d9de3187a9012e2b3/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesAdmin.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesAdminInternal.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/da64281ff9a0be20c800f1c3e61a17bce99fc90d/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesDerivativeAdmin.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/48e921db2f31fe4c9afe954399a45d78237e1e70/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesDerivativeTypesAdmin.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/main/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesManaged.sol";



contract OpenRolesAdmin is IOpenVersion, IOpenRolesAdmin, IOpenRolesAdminInternal {

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    string name = "RESERVED_OPEN_ROLES_ADMIN"; 
    uint256 version = 10;  

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

    constructor( address _rootAdmin) {        
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

    function isDerivativeContractManagementActive(string memory _dApp) view external returns (bool _active)  { 
        return derivativeContractAdminActiveByDApp[_dApp];
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
        
        // remove any derivative contract management 
        if(derivativeContractAdminActiveByDApp[_dApp]){
            removeDerivativeContractManagementForDAppInternal(_dApp);
        }

        // remove contracts first
        removeContractsForDappInternal(_dApp, contractsByDapp[_dApp]);
        delete contractsByDapp[_dApp];
        
        // then remove roles and associated users
        removeRolesForDappInternal(_dApp, rolesByDapp[_dApp]);
        delete rolesByDapp[_dApp];
        
        // then remove dApp
        _dApp.remove(dappList);
        delete isKnownDappByDapp[_dApp];
        return true; 
    }
    
        // dApp wide roles
    function addRolesForDapp(string memory _dApp, string [] memory _roleNames) override external returns ( bool _added){
        doSecurity(msg.sender, "addRolesForDapp");
        return addRolesForDappInternal(_dApp, _roleNames); 
    }

    function removeRolesForDapp(string memory _dApp, string [] memory _roleNames) override external returns (bool _removed){
        doSecurity(msg.sender, "removeRolesForDapp");
        return removeRolesForDappInternal(_dApp, _roleNames);         
    }

    // dApp core contracts
    function addContractsForDapp(string memory _dApp, address [] memory _contracts, string [] memory _contractNames) override external returns (bool _added){
        doSecurity(msg.sender, "addContractsForDapp");        
        return addContractsForDappInternal(_dApp, _contracts, _contractNames);
    }

    function addManagedContractsForDapp(string memory _dApp, address [] memory _contracts) external returns (bool _added){
        doSecurity(msg.sender, "addManagedContractsForDapp");
        return addManagedContractsForDappInternal(_dApp, _contracts);
    }

    function removeContractsForDapp(string memory _dApp, address [] memory _contractAddresses) override external returns (bool _removed){
        doSecurity(msg.sender, "removeContractsForDapp");
        return removeContractsForDappInternal(_dApp, _contractAddresses); 
    }    

    // mapping functions 

        // add users to dApp wide role 
    function addUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) override external returns (bool _added){
        doSecurity(msg.sender, "addUserAddressesForRoleForDapp");
        return addUserForRoleForDappInternal(_dApp, _role, _userAddresses);
    }

    function removeUserAddressesForRoleForDapp(string memory _dApp, string memory _role,address [] memory _userAddresses) override external returns (bool _removed){
        doSecurity(msg.sender, "removeUserAddressesForRoleForDapp");
        return removeUserAddressesForRoleForDappInternal(_dApp, _role, _userAddresses); 
    }

        // add core contracts for dApp wide role 
    function addContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) override external returns (bool _added){
        doSecurity(msg.sender, "addContractsForRoleForDapp");
        return addContractsForRoleForDappInternal(_dApp, _role, _contracts); 
    }

    function removeContractsForRoleForDapp(string memory _dApp, string memory _role, address [] memory _contracts) override external returns (bool _removed){
        doSecurity(msg.sender, "removeContractsForRoleForDapp");        
        return removeContractsForRoleForDappInternal(_dApp, _role, _contracts); 
    }
    
        // add functions for contract for dApp wide role 
    function addFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) override external returns (bool _added){
        doSecurity(msg.sender, "addFunctionForRoleForContractForDapp");
        return addFunctionForRoleForContractForDappInternal(_dApp, _role, _contract, _functions);
    }

    function removeFunctionForRoleForContractForDapp(string memory _dApp, string memory _role, address _contract, string [] memory _functions) override  external returns (bool _removed){
        doSecurity(msg.sender, "removeFunctionForRoleForContractForDapp");      
        return removeFunctionForRoleForContractForDappInternal(_dApp, _role, _contract, _functions); 
    }

    function addDerivativeContractManagementForDApp(address _derivativeContractAdmin, address _derivativeContractTypesAdmin, string memory _dApp) override external returns (bool _added){
        doSecurity(msg.sender, "addDerivativeContractManagementForDApp");
        if(!derivativeContractAdminActiveByDApp[_dApp]){
            derivativeContractAdminActiveByDApp[_dApp] = true; 
            derivativeContractAdminAddressByDApp[_dApp] = _derivativeContractAdmin;
            derivativeContractTypesAdminAddressByDApp[_dApp] = _derivativeContractTypesAdmin; 
            
            address [] memory derivativeManagement_ = new address[] (2);
            derivativeManagement_[0] = _derivativeContractAdmin;
            derivativeManagement_[1] = _derivativeContractTypesAdmin;

            addManagedContractsForDappInternal(_dApp, derivativeManagement_);
            return true; 
        }
        return false; 
    }

    function removeDerivativeContractManagementForDApp( string memory _dApp) override external returns (bool _removed){
        doSecurity(msg.sender, "removeDerivativeContractManagementForDApp");        
        return removeDerivativeContractManagementForDAppInternal(_dApp); 
    }
   
    // ================================== INTERNAL FUNCTIONS ===================================================

    function addContractsForDappInternal(string memory _dApp, address [] memory _contracts, string [] memory _contractNames) internal returns (bool _added){
        for(uint256 x = 0; x < _contracts.length; x++){
            address contractAddress_ =  _contracts[x]; 
            
            if(!isKnownContractByDapp[_dApp][contractAddress_]){

                contractsByDapp[_dApp].push(contractAddress_);
                if(_contractNames.length == _contracts.length){
                    contractNameByContractByDapp[_dApp][contractAddress_] = _contractNames[x];
                }
                else { 
                    IOpenRolesManaged iorm = IOpenRolesManaged(contractAddress_);
                    contractNameByContractByDapp[_dApp][contractAddress_] = iorm.getName();
                }
                isKnownContractByDapp[_dApp][contractAddress_] = true; 
            }

        }
        return true; 
    }

    function addUserForRoleForDappInternal(string memory _dApp, string memory _role,address [] memory _userAddresses) internal returns (bool _added) {
        for(uint256 x = 0; x < _userAddresses.length; x++){
            address user_ = _userAddresses[x];
            addUserForRoleForDappInternal(_dApp, _role, user_);
        }
        return true; 
    }

    function addUserForRoleForDappInternal(string memory _dApp, string memory _role, address  _user) internal returns (bool _added){
            require(!isKnownUserByRoleByDapp[_dApp][_role][_user], string(" Open Roles Admin : addUserAddressesForRoleForDapp : 00 : - attempted to add known user for role  for dApp : ").append(string(abi.encodePacked(_user))));
            usersByRoleByDapp[_dApp][_role].push(_user);
            isKnownUserByRoleByDapp[_dApp][_role][_user] = true; 
            return true; 
    }

    function addManagedContractsForDappInternal(string memory _dApp, address [] memory _contracts) internal returns (bool _added) {
        string [] memory zero = new string[](0);
        // add zero for managed access         
        addContractsForDappInternal(_dApp, _contracts, zero);

        for(uint256 x = 0; x < _contracts.length; x++){
            address contract_ = _contracts[x];
            
            IOpenRolesManaged iorm = IOpenRolesManaged(contract_);
            
            // configure roles 
            string [] memory defaultRoles_ = iorm.getDefaultRoles();  
            addRolesForDappInternal(_dApp, defaultRoles_);
            
            for(uint256 y = 0; y < defaultRoles_.length; y++){ 
                string memory role_ = defaultRoles_[y];
                addContractsForRoleForDappInternal(_dApp, role_ ,getArrayAddress(contract_) );
                if(iorm.hasDefaultFunctions(role_)) {
                    string [] memory functions_ = iorm.getDefaultFunctions(role_);
                    addFunctionForRoleForContractForDappInternal(_dApp, role_, contract_, functions_);
                }
            
            }
        }
        return true;
    }

 

    function addRolesForDappInternal(string memory _dApp, string [] memory _roleNames) internal returns(bool _added) {
        for(uint256 x = 0; x < _roleNames.length; x++){
            string memory role_ = _roleNames[x];
            if(!isKnownRoleByDapp[_dApp][role_]){ 
                rolesByDapp[_dApp].push(role_);
                isKnownRoleByDapp[_dApp][role_] = true;
            }
        }
        return true; 
    }

    function addContractsForRoleForDappInternal(string memory _dApp, string memory _role, address [] memory _contracts) internal returns (bool _added){
        for(uint256 x = 0; x < _contracts.length; x++){
            address contract_ = _contracts[x];

            if(!isKnownContractByRoleByDapp[_dApp][_role][contract_]){

                contractsByRoleByDapp[_dApp][_role].push(contract_); 
                isKnownContractByRoleByDapp[_dApp][_role][contract_] = true;
            }
            if(!isKnownRoleByDappByContract[contract_][_dApp][_role]){

                rolesByDappByContract[contract_][_dApp].push(_role);
                isKnownRoleByDappByContract[contract_][_dApp][_role] = true; 
            }
        }
        return true;  
    }

    function addFunctionForRoleForContractForDappInternal(string memory _dApp, string memory _role, address _contract, string [] memory _functions) internal returns (bool _added){
       for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            if(!isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_]){
                functionsByContractByRoleByDapp[_dApp][_role][_contract].push(function_);
                isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_] = true; 
            }
        }
        return true;
    }

    function removeRolesForDappInternal(string memory _dApp, string [] memory _roleNames) internal returns (bool _removed) {
        string [] memory roles_ = rolesByDapp[_dApp];        
        string [] memory remainingRoles_ = new string[](roles_.length - _roleNames.length);
        uint256 y = 0; 
        for(uint256 x = 0; x < roles_.length; x++){
            string memory role_ = roles_[x];
            if(role_.isContained(_roleNames)){
                // remove contract and function associations
                removeContractsForRoleForDappInternal(_dApp, role_,contractsByRoleByDapp[_dApp][role_]);

                // remove user associations 
                removeUserAddressesForRoleForDappInternal(_dApp, role_,  usersByRoleByDapp[_dApp][role_]);
                
                // remove knownledge of the role 
                role_.remove(rolesByDapp[_dApp]);
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


    function removeContractsForRoleForDappInternal(string memory _dApp, string memory _role, address [] memory _contracts) internal returns (bool _removed) {
        address [] memory contracts_ = contractsByRoleByDapp[_dApp][_role];
        for(uint256 x = 0; x < contracts_.length; x++){
            address contract_ = contracts_[x];
            if(contract_.isContained(_contracts)) {
                removeRoleContractInternal(_dApp, _role, contract_);           
            }
        }
        return true; 
    }

    function removeContractsForDappInternal(string memory _dApp, address [] memory _contractAddresses) internal returns (bool _removed) {
       address [] memory contractAddresses_ = contractsByDapp[_dApp]; 
        address [] memory remainingContractAddresses_ = new address[](contractAddresses_.length - _contractAddresses.length);
        uint256 x = 0; 
        for(uint256 y = 0; y < contractAddresses_.length; y++) {
            address contractAddress_ = contractAddresses_[y];
            if(contractAddress_.isContained(_contractAddresses)) {
                
                // remove all role associations                               
                string [] memory roles_ = rolesByDappByContract[contractAddress_][_dApp];
                for(uint256 z  = 0; z < roles_.length; z++){
                    string memory role_ = roles_[z];
                    removeRoleContractInternal(_dApp, role_, contractAddress_);
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

    function removeRoleContractInternal(string memory _dApp, string memory _role, address _contract ) internal returns (bool _removed){
        
        // remove function -> contract -> role associations
        removeFunctionForRoleForContractForDappInternal(_dApp, _role, _contract, functionsByContractByRoleByDapp[_dApp][_role][_contract]);
        
        // remove role -> contract associations
        if(isKnownRoleByDappByContract[_contract][_dApp][_role]){
            string [] memory roles_ = rolesByDappByContract[_contract][_dApp];
            rolesByDappByContract[_contract][_dApp] = _role.remove(roles_);
            isKnownRoleByDappByContract[_contract][_dApp][_role] = false;
        }

        // remove contract -> role associations
        if(isKnownContractByRoleByDapp[_dApp][_role][_contract]){
            address [] memory contracts_ = contractsByRoleByDapp[_dApp][_role];
            contractsByRoleByDapp[_dApp][_role] = _contract.remove(contracts_);        
            isKnownContractByRoleByDapp[_dApp][_role][_contract] = false;           
        }
        return true; 
    }

    function removeFunctionForRoleForContractForDappInternal(string memory _dApp, string memory _role, address _contract, string [] memory _functions ) internal returns (bool _removed) {
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
        functionsByContractByRoleByDapp[_dApp][_role][_contract] = remainingFunctions_;
        return true; 
    }

    function removeUserAddressesForRoleForDappInternal(string memory _dApp, string memory _role,address [] memory _userAddresses) internal returns (bool _removed) {
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

    function removeDerivativeContractManagementForDAppInternal(string memory _dApp) internal returns (bool _removed) {
        if(derivativeContractAdminActiveByDApp[_dApp]){
            
            address [] memory derivativeManagement_ = new address[] (2);
            derivativeManagement_[0] = derivativeContractAdminAddressByDApp[_dApp] ;
            derivativeManagement_[1] = derivativeContractTypesAdminAddressByDApp[_dApp];
            removeContractsForDappInternal(_dApp, derivativeManagement_);
                        
            delete derivativeContractAdminAddressByDApp[_dApp] ;
            delete derivativeContractTypesAdminAddressByDApp[_dApp]; 

            derivativeContractAdminActiveByDApp[_dApp] = false; 
            return true; 
        }

    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(abi.encodePacked(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

    function getArrayAddress(address a) internal pure returns (address [] memory _b) { 
        address [] memory b = new address[](1);
        b[0] = a; 
        return b; 
    }

    function doSecurity(address _user, string memory _function) view internal returns (bool _done) {              
        require(_user == rootAdmin, string(" Open Roles Admin : ").append(_function).append(string(" 00 : - admin only")));                
        return true; 
    }

}