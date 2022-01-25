//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.0 <0.9.0;

interface IOpenRoles { 


    // dApp scope
    function isAllowed(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) view external returns (bool _isAllowed);

    function isBarred(string memory _dApp, string memory _role, address _contract, string memory _function, address _srcSender ) view external returns (bool _isBarred);


    // derivative contract scope 
    function isAllowed(address _contract, string memory _role, string memory _function, address _srcSender ) view external returns (bool _isAllowed);

    function isBarred(address _contract, string memory _role, string memory _function, address _srcSender ) view external returns (bool _isBarred);

    function getDerivativeContractsAdmin(string memory _dApp) external returns (address _derivativeAdminAddress);

}

