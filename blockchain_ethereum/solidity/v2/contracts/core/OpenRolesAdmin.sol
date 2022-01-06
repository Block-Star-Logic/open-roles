//"SPDX-License-Identifier: APACHE 2.0"

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-libraries/blob/main/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

import "https://github.com/Block-Star-Logic/open-version/blob/main/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/main/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRolesAdmin.sol";

import "https://github.com/Block-Star-Logic/open-roles/blob/main/blockchain_ethereum/solidity/v2/contracts/core/OpenRoles.sol";

contract OpenRolesAdmin is IOpenVersion, IOpenRolesAdmin {

    using LOpenUtilities for string; 
    using LOpenUtilities for string[];
    using LOpenUtilities for address; 

    string name; 
    uint256 version = 2; 

    address rootAdmin; 

    string [] dappList; 

    OpenRoles openRoles; 

    bool openRolesLinked;

    string [] passList; 

    mapping(string=>uint256) passUsageByPass; 

    mapping(string=>bool) isKnownDappByDapp;

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
    }

    function getVersion() override view external returns (uint256 _version){
        return version; 
    }

    function getName() override view external returns (string memory _contractName){
        return name; 
    }


    function linkOpenRoles(address _openRolesAddress, string memory _pass) external returns (bool _linked) {
        doPassSecurity(msg.sender, "linkOpenRoles", _openRolesAddress, _pass); 
        openRoles = OpenRoles(_openRolesAddress);
        openRolesLinked = true; 
        return true; 
    }

    function unlinkOpenRoles() external returns (bool _unlinked) {
        doSecurity(msg.sender, "unlinkOpenRoles");
        openRoles = OpenRoles(address(0));
        openRolesLinked = false;
        return true; 
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
        dappList.push(_dApp);
        isKnownDappByDapp[_dApp]  = true; 
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
            
            require(!isKnownContractByDapp[_dApp][contractAddress_], string(" Open Roles Admin - addContractsForDapp : 00 : - attempted to add dApp known contract : ").append(string(abi.encodePacked(contractAddress_)))); 

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
            require(!isKnownUserByRoleByDapp[_dApp][_role][user_], string(" Open Roles Admin - addUserAddressesForRoleForDapp : 00 : - attempted to add known user for role  for dApp : ").append(string(abi.encodePacked(user_))));
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

            require(!isKnownContractByRoleByDapp[_dApp][_role][contract_], string(" Open Roles Admin - addContractsForRoleForDapp : 00 : - attempted to add known contract for role for dApp : ").append(string(abi.encodePacked(contract_))));

            contractsByRoleByDapp[_dApp][_role].push(contract_); 
            isKnownContractByRoleByDapp[_dApp][_role][contract_] = true;
            
            require(!isKnownRoleByDappByContract[contract_][_dApp][_role], string(" Open Roles Admin - addContractsForRoleForDapp : 01 : - attempted to add known role for contract  for dApp : ").append(_role).append(" : ").append(string(abi.encodePacked(contract_))));

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
            require(!isKnownFunctionsByContractByRoleByDapp[_dApp][_role][_contract][function_], string(" Open Roles Admin - addFunctionForRoleForContractForDapp : 01 : - attempted to add known function for contract for role : ").append(function_).append(" : ").append(string(abi.encodePacked(_contract))).append(" : ").append(_role));
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

     // derivative contracts 

        // listing functions    
    
    mapping(string=>string[]) derivativeContractTypesByDapp; 
    mapping(string=>mapping(string=>bool)) isKnownDerivativeContractTypeByDapp;     

    mapping(string=>mapping(string=>string[])) derivativeContactTypesByRoleByDapp; 
    mapping(string=>mapping(string=>string[])) rolesByDerivativeContractTypesByDapp; 
    mapping(string=>mapping(string=>mapping(string=>bool))) isKnownMappingByContractTypeByRoleByDapp; 
    

    mapping(string=>mapping(string=>mapping(string=>string[]))) functionsByDerivativeContractTypeByRoleByDapp;     
    mapping(string=>mapping(string=>mapping(string=>mapping(string=>bool)))) isKnownFunctionByContractTypeByRoleByDapp;
    

     // derivative contracts 

        // listing functions 
    function listDerivativeContractTypesForDapp(string memory _dApp) override view external returns (string [] memory _contractTypes){
        return derivativeContractTypesByDapp[_dApp];
    }

    function listRolesForDerivativeContractType(string memory _dApp, string memory _derivativeContactType) override view external returns (string [] memory _roles){
        return rolesByDerivativeContractTypesByDapp[_dApp][_derivativeContactType];
    } 

    function listFunctionsForRoleForDerivativeContractType(string memory _dApp, string memory _derivativeContractType, string memory _role) override view external returns (string [] memory _functions){
        return functionsByDerivativeContractTypeByRoleByDapp[_dApp][_role][_derivativeContractType];
    }


    function listDerivativeContractsForDapp(string memory _dApp) override view external returns(string [] memory _contractTypes, address [] memory _derivativeContracts ){
        _contractTypes = derivativeContractTypesByDapp[_dApp]; 
        ( _derivativeContracts, _contractTypes) = openRoles.listDerivativeContractAddressesForContractTypeForDapp(_dApp, _contractTypes);
        return  (_contractTypes, _derivativeContracts);
    }

    function listDerivativeContractsForContractType(string memory _dApp, string memory _derivativeContactType) override view external returns (address [] memory _derivativeContracts){
        require(openRolesLinked, string(" Open Roles Admin - listDerivativeContractsForContractType : 00 : Open Roles NOT linked."));
        string [] memory c = new string[](1);
        c[1] = _derivativeContactType; 
        string[] memory contractTypes_;
        (_derivativeContracts, contractTypes_) = openRoles.listDerivativeContractAddressesForContractTypeForDapp(_dApp, c);
        return _derivativeContracts;
    }

    function listDerivativeContractTypesForRole(string memory _dApp, string memory _role) override view external returns (string [] memory _contractTypes){
        return derivativeContactTypesByRoleByDapp[_dApp][_role];
    }

    function listDerivativeContractsForRole(string memory _dApp, string memory _role) override view external returns (address [] memory _derivativeContracts, string [] memory _contractTypes){
        string [] memory contractTypes_ = this.listDerivativeContractTypesForRole(_dApp, _role);
        return openRoles.listDerivativeContractAddressesForContractTypeForDapp(_dApp, contractTypes_);
    }

    function listDerivativeContractsForRoleForContractType(string memory _dApp,  string memory _role, string memory _derivativeContactType ) override view external returns (address [] memory _derivativeContracts){
        require(_derivativeContactType.isContained(derivativeContactTypesByRoleByDapp[_dApp][_role]), string(" Open Roles Admin - listDerivativeContractsForRoleForContractType : 00 : no association for role and contractType ").append(_role));        
        return this.listDerivativeContractsForContractType(_dApp, _derivativeContactType);
    }

        // derivative contract listing
    function listRolesForDerivativeContract(address _derivativeContract) override view external returns (string [] memory _roles){
        require(openRolesLinked, string(" Open Roles Admin - listRolesForDerivativeContract : 00 : Open Roles NOT linked."));
        string [] memory derivativeContractTypes_ = openRoles.listDerivativeContractTypesForAddress(_derivativeContract);
        string memory dapp_ = openRoles.getDapp(_derivativeContract); 
        _roles = new string[](0);
        for(uint256 x = 0; x < derivativeContractTypes_.length; x++) {
            string memory derivativeContractType_ = derivativeContractTypes_[x];
            string [] memory roles_ = rolesByDerivativeContractTypesByDapp[dapp_][derivativeContractType_];
            _roles = _roles.append(roles_);
        }
        return _roles; 
    } 

    function listFunctionsForRoleForDerivativeContract(address _derivativeContract, string memory _role) override view external returns (string [] memory _functions){
        require(openRolesLinked, string(" Open Roles Admin - listRolesForDerivativeContract : 00 : Open Roles NOT linked."));
        string memory dapp_ = openRoles.getDapp(_derivativeContract); 
        string [] memory derivativeContractTypes_ = openRoles.listDerivativeContractTypesForAddress(_derivativeContract);
        string [] memory roleDerivativeContractTypes_ = derivativeContactTypesByRoleByDapp[dapp_][_role];
        _functions = new string[](0);
        for(uint256 x = 0; x < roleDerivativeContractTypes_.length; x++ ){
            string memory roleDerivativeContractType_ = roleDerivativeContractTypes_[x];
            if(roleDerivativeContractType_.isContained(derivativeContractTypes_)) { 
               _functions = _functions.append(functionsByDerivativeContractTypeByRoleByDapp[roleDerivativeContractType_][_role][dapp_]);        
            }
        }
        return _functions;
    }

    function listUsersForRoleForDerivativeContract(address _derivativeContract, string memory _role) override view external returns (address [] memory _userAddresses){
        require(openRolesLinked, string(" Open Roles Admin - listRolesForDerivativeContract : 00 : Open Roles NOT linked."));
        string memory dapp_ = openRoles.getDapp(_derivativeContract); 
        return this.listUsersForRole(dapp_,_role);
    }

    
    // derivative contacts - derivative contracts can only be "owned" by one dApp but can be shared to other dApp contexts

        // dApp wide 
    function addDerivativeContractTypesForDapp(string memory _dApp, string [] memory _contractTypes) override external returns (bool _added){
        doSecurity(msg.sender, "addDerivativeContractTypesForDapp");

        for(uint256 x = 0; x < _contractTypes.length; x++){
            string memory contractType_ = _contractTypes[x];
            require(!isKnownDerivativeContractTypeByDapp[_dApp][contractType_], string(" Open Roles Admin - addDerivativeContractTypesForDapp : 00 : attempt to add known contract Type :- ").append(contractType_));            
            derivativeContractTypesByDapp[_dApp].push(contractType_);  
            isKnownDerivativeContractTypeByDapp[_dApp][contractType_] = true;
        }
        return true;
    }

    function removeDerivativeContractTypesForDapp(string memory _dApp, string [] memory _contractTypes) override external returns (bool _removed){
        doSecurity(msg.sender, "removeDerivativeContractTypesForDapp");

        string [] memory contractTypes_ = derivativeContractTypesByDapp[_dApp];
        string [] memory remainingContractTypes_ = new string[](contractTypes_.length - _contractTypes.length);
        
        uint256 y = 0; 
        for(uint256 x = 0; x < contractTypes_.length; x++){
            string memory contractType_ = contractTypes_[x];
            if(contractType_.isContained(contractTypes_)){
                this.unmapRolesFromContractType(_dApp, contractType_, rolesByDerivativeContractTypesByDapp[_dApp][contractType_]);
                isKnownDerivativeContractTypeByDapp[_dApp][contractType_] = false; 
            }
            else {
                remainingContractTypes_[y] = contractType_;
                y++;
            }            
        }
        derivativeContractTypesByDapp[_dApp] = remainingContractTypes_;
        return true;
    }

    // map is used because the values are already known internal to OpenRolesAdmin
    function mapRolesToContractType(string memory _dApp, string memory _contractType, string [] memory _roles) override external returns (bool _mapped){
        doSecurity(msg.sender, "mapRolesToContractType");

        require(isKnownDerivativeContractTypeByDapp[_dApp][_contractType], string(" Open Roles Admin - mapRolesToContractType : 00 : attempt to map unknown contract Type : ").append(_contractType));  
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x];
            
            require(isKnownRoleByDapp[_dApp][role_], string(" Open Roles Admin - mapRolesToContractType : 01 : attempt to map unknown role : ").append(role_));
            require(!isKnownMappingByContractTypeByRoleByDapp[_dApp][role_][_contractType], string(" Open Roles Admin - mapRolesToContractType : 02 : attempt to create known mapping : ").append(role_).append(" : ").append(_contractType));

            rolesByDerivativeContractTypesByDapp[_dApp][_contractType].push(role_);        
            derivativeContactTypesByRoleByDapp[_dApp][role_].push(_contractType);    

            isKnownMappingByContractTypeByRoleByDapp[_dApp][role_][_contractType] = true;       
        }
        return true;
    }
    
    function unmapRolesFromContractType(string memory _dApp, string memory _contractType, string [] memory _roles) override external returns (bool _unmapped){
        doSecurity(msg.sender, "unmapRolesFromContractType");
        
        for(uint256 x = 0; x < _roles.length; x++){
            string memory role_ = _roles[x]; 
            require(isKnownMappingByContractTypeByRoleByDapp[_dApp][role_][_contractType], string(" Open Roles Admin - unmapRolesFromContractType : 02 : attempt to unmap unknown mapping ").append(role_).append(" : ").append(_contractType) );

            // remove reverse mapping
            rolesByDerivativeContractTypesByDapp[_dApp][_contractType] = role_.remove(rolesByDerivativeContractTypesByDapp[_dApp][_contractType]);
            // remove forward mapping
            derivativeContactTypesByRoleByDapp[_dApp][role_] = _contractType.remove(derivativeContactTypesByRoleByDapp[_dApp][role_]);
            // remove functions
            this.removeFunctionsForRoleForDerivativeContactType(_dApp, _contractType, role_, functionsByDerivativeContractTypeByRoleByDapp[_dApp][role_][_contractType]);
            
            isKnownMappingByContractTypeByRoleByDapp[_dApp][role_][_contractType] = false; 
        }
        return true;
    }

    function addFunctionsForRoleForDerivativeContactType(string memory _dApp, string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _added){
        doSecurity(msg.sender, "addFunctionsForRoleForDerivativeContactType");
        require(isKnownMappingByContractTypeByRoleByDapp[_dApp][_role][_contractType],"");
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            require(!isKnownFunctionByContractTypeByRoleByDapp[_dApp][_role][_contractType][function_], string(" Open Roles Admin - addFunctionsForRoleForDerivativeContactType : 00 : attempt to add existing function to contract type to role : ").append(function_).append(" : ").append(_contractType).append(" : ").append(_role));
            functionsByDerivativeContractTypeByRoleByDapp[_dApp][_role][_contractType].push(function_);
            isKnownFunctionByContractTypeByRoleByDapp[_dApp][_role][_contractType][function_] = true; 
        }
        return true;
    }

    function removeFunctionsForRoleForDerivativeContactType(string memory _dApp, string memory _contractType, string memory _role, string [] memory _functions) override external returns (bool _removed){
        doSecurity(msg.sender, "removeFunctionsForRoleForDerivativeContactType");

        require(isKnownMappingByContractTypeByRoleByDapp[_dApp][_role][_contractType], string(" Open Roles Admin - addFunctionsForRoleForDerivativeContactType : 00 : attempt to remove functions for unknown mapping : ").append(_contractType).append(" : ").append(_role));
        for(uint256 x = 0; x < _functions.length; x++){
            string memory function_ = _functions[x];
            functionsByDerivativeContractTypeByRoleByDapp[_dApp][_role][_contractType] = function_.remove(functionsByDerivativeContractTypeByRoleByDapp[_dApp][_role][_contractType]);
            isKnownFunctionByContractTypeByRoleByDapp[_dApp][_role][_contractType][function_] = false; 
        }
        return true;
    }

    function addValidPass(string memory _pass) external returns (bool _added){ 
        doSecurity(msg.sender, "removeFunctionForRoleForContractForDapp");
        passList.push(_pass);
        passUsageByPass[_pass] = 0; 
        return true; 
    }

    function removePass(string memory _pass) external returns (bool _removed){
        doSecurity(msg.sender, "removeFunctionForRoleForContractForDapp");
        require(_pass.isContained(passList), string(" Open Roles Admin - removePass : 00 : attempt to remove unknown pass ").append(_pass));
        require(passUsageByPass[_pass] == 0, string(" Open Roles Admin - removePass : 01 : attempt to remove used pass ").append(_pass));
        passList = _pass.remove(passList);
        delete passUsageByPass[_pass];
        return true; 
    }

    function doSecurity(address _user, string memory _function) view internal returns (bool _done) {              
        require(_user == rootAdmin, " Open Roles Admin : 00 : - admin only");                

        return true; 
    }

    function doPassSecurity(address _sender, string memory _function, address _user, string memory _pass) internal returns (bool _done){
        require(_pass.isContained(passList), string("Open Roles Admin - removePass : 00 : attempt to use unknown pass ").append(_pass));
        require(passUsageByPass[_pass] == 0, string("Open Roles Admin - removePass : 01 : attempt to use expended pass ").append(_pass)); 
        /// do some more validation 

        passUsageByPass[_pass] = block.timestamp; 
        return true; 
    }

}