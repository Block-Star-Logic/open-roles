//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;


interface IOpenRolesAdminInternal {

    function isKnownRoleByDappInternal(string memory _dapp, string memory _role) view external returns (bool _isKnownRoleByDapp);

    function listUsersForRoleInternal(string memory _dApp, string memory _role)  view external returns (address[] memory _userAddresses);
}