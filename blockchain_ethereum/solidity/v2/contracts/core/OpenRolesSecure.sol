// SPDX-License-Identifier: APACHE 2.0
pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-version/blob/e161e8a2133fbeae14c45f1c3985c0a60f9a0e54/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-roles/blob/fc410fe170ac2d608ea53e3760c8691e3c5b550e/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";
import "https://github.com/Block-Star-Logic/open-libraries/blob/703b21257790c56a61cd0f3d9de3187a9012e2b3/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

contract OpenRolesSecure { 

    using LOpenUtilities for string; 

    IOpenRoles roleManager; 
    address self; 
    bool private roleSecurityActive = true;
    string dappName;

    struct ConfigurationItem { 
        string name;
        address itemAddress; 
        uint256 version; 
    }
    ConfigurationItem [] configuration;
    mapping(string=>bool) hasConfigurtionItemByName; 

    constructor(string memory _dappName) { 
        self = address(this);
        dappName = _dappName;
    }        

    function listConfiguration () view external returns (string [] memory _names, address [] memory _addresses, uint256 [] memory _versions) {
        _names = new string[](configuration.length);
        _addresses = new address[](configuration.length);
        _versions = new uint256[](configuration.length);
        for(uint256 x = 0; x < configuration.length; x++){
            ConfigurationItem memory item = configuration[x];
            _names[x] = item.name; 
            _addresses[x] = item.itemAddress;
            _versions[x] = item.version;
        }
        return (_names, _addresses, _versions);
    }

    // ============================== INTERNAL ====================

    function setRoleManager(address _openRolesAddress) internal returns (bool _set){        
         roleManager = IOpenRoles(_openRolesAddress);       
         return true; 
    }

    function isSecure(string memory _role, string memory _function) view internal returns (bool) {
        if(roleSecurityActive){
            return roleManager.isAllowed(dappName, _role, self, _function, msg.sender);
        }
       return true; 
    }
        
    function isSecureBarring(string memory _role, string memory _function) view internal returns (bool) {       
       if(roleSecurityActive){
            if(roleManager.isBarred(dappName, _role, self, _function, msg.sender)){
                return false; 
            }
       }
       return true; 
    }

    function addConfigurationItem(string memory _name, address _address, uint256 _version) internal returns(bool){
        ConfigurationItem memory item = ConfigurationItem({
                                                            name : _name,
                                                            itemAddress : _address,  
                                                            version : _version 
                                                        });
        if(hasConfigurtionItemByName[_name]) {
            removeConfigurationItem(_name);
        }
        configuration.push(item);
        hasConfigurtionItemByName[_name] = true; 
        return true; 
    }

    function addConfigurationItem(address _address) internal returns (bool) {
        IOpenVersion ov_ = IOpenVersion(_address);
        return addConfigurationItem(ov_.getName(), _address, ov_.getVersion());
    }

    function removeConfigurationItem(string memory _name) internal returns (bool _removed) {
        ConfigurationItem [] memory newConfiguration = new ConfigurationItem[](configuration.length-1);
        uint256 y = 0; 
        for(uint256 x = 0; x < configuration.length; x++) {
            ConfigurationItem memory item = configuration[x];
            if(!item.name.isEqual(_name)){
                if(y == newConfiguration.length){ // not found 
                    return false; 
                }
                newConfiguration[y] = item; 
                y++;
            }
        }
        configuration = newConfiguration; 
        hasConfigurtionItemByName[_name] = false; 
        return true; 
    }
}
