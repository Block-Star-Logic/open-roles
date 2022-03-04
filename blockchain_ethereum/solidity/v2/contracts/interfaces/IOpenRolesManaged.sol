//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/Block-Star-Logic/open-version/blob/e161e8a2133fbeae14c45f1c3985c0a60f9a0e54/blockchain_ethereum/solidity/V1/interfaces/IOpenVersion.sol";

interface IOpenRolesManaged is IOpenVersion { 

    function getDefaultRoles() view external returns (string [] memory _roles);

    function hasDefaultFunctions(string memory _role) view external returns(bool _hasFunctions); 

    function getDefaultFunctions(string memory _role) view external returns (string [] memory _functions);

}