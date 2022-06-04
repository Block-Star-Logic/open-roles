// SPDX-License-Identifier: APACHE 2.0
pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-version/blob/e161e8a2133fbeae14c45f1c3985c0a60f9a0e54/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";
import "https://github.com/Block-Star-Logic/open-roles/blob/fc410fe170ac2d608ea53e3760c8691e3c5b550e/blockchain_ethereum/solidity/v2/contracts/interfaces/IOpenRoles.sol";
import "https://github.com/Block-Star-Logic/open-libraries/blob/703b21257790c56a61cd0f3d9de3187a9012e2b3/blockchain_ethereum/solidity/V1/libraries/LOpenUtilities.sol";

 abstract contract OpenRolesSecure { 

    using LOpenUtilities for string; 

    IOpenRoles roleManager; 
    address self; 
    bool roleSecurityActive = true;
    string dappName;

    struct ConfigurationItem { 
        string name;
        address itemAddress; 
        uint256 version; 
    }
    string [] configurationNames;
    mapping(string=>bool) hasConfigurationItemByName; 
    mapping(string=>ConfigurationItem) configurationitemByName; 

    constructor() {
        self = address(this);
    }

    function listConfiguration () view external returns (string [] memory _names, address [] memory _addresses, uint256 [] memory _versions) {
        _names = new string[](configurationNames.length);
        _addresses = new address[](configurationNames.length);
        _versions = new uint256[](configurationNames.length);
        for(uint256 x = 0; x < configurationNames.length; x++){
            string memory _name = configurationNames[x];
            ConfigurationItem memory item = configurationitemByName[_name];
            _names[x] = item.name; 
            _addresses[x] = item.itemAddress;
            _versions[x] = item.version;
        }
        return (_names, _addresses, _versions);
    }
   // ============================== INTERNAL ====================

    function isSecure(string memory _role, string memory _function) virtual view internal returns (bool); 

    function isSecureBarring(string memory _role, string memory _function) virtual view internal returns (bool);


    function setRoleManager(address _openRolesAddress) internal returns (bool _set){        
         roleManager = IOpenRoles(_openRolesAddress);       
         return true; 
    }

    function addConfigurationItem(string memory _name, address _address, uint256 _version) internal returns(bool){
        ConfigurationItem memory item = ConfigurationItem({
                                                            name : _name,
                                                            itemAddress : _address,  
                                                            version : _version 
                                                        });
        if(hasConfigurationItemByName[_name]) {
            removeConfigurationItem(_name);
        }

        configurationNames.push(item.name);
        hasConfigurationItemByName[_name] = true; 
        configurationitemByName[_name] = item;
        return true; 
    }

    function addConfigurationItem(address _address) internal returns (bool) {
        IOpenVersion ov_ = IOpenVersion(_address);
        return addConfigurationItem(ov_.getName(), _address, ov_.getVersion());
    }

    function removeConfigurationItem(string memory _name) internal returns (bool _removed) {
        configurationNames = _name.remove(configurationNames);
        delete hasConfigurationItemByName[_name];
        delete configurationitemByName[_name];
        return true; 
    }
}
