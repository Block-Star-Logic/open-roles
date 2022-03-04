const openRolesAdminAbi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_rootAdmin",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_contracts",
				"type": "address[]"
			},
			{
				"internalType": "string[]",
				"name": "_contractNames",
				"type": "string[]"
			}
		],
		"name": "addContractsForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_contracts",
				"type": "address[]"
			}
		],
		"name": "addContractsForRoleForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "addDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_derivativeContractAdmin",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_derivativeContractTypesAdmin",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "addDerivativeContractManagementForDApp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "_contract",
				"type": "address"
			},
			{
				"internalType": "string[]",
				"name": "_functions",
				"type": "string[]"
			}
		],
		"name": "addFunctionForRoleForContractForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_contracts",
				"type": "address[]"
			}
		],
		"name": "addManagedContractsForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "_roleNames",
				"type": "string[]"
			}
		],
		"name": "addRolesForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_userAddresses",
				"type": "address[]"
			}
		],
		"name": "addUserAddressesForRoleForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_added",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_contract",
				"type": "address"
			}
		],
		"name": "getDappForDerivativeContract",
		"outputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "getDerivativeContractTypesAdmin",
		"outputs": [
			{
				"internalType": "address",
				"name": "_derivativeContractTypesAdminAddress",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "getDerivativeContractsAdmin",
		"outputs": [
			{
				"internalType": "address",
				"name": "_derivativeContractAdminAddress",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getName",
		"outputs": [
			{
				"internalType": "string",
				"name": "_contractName",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getVersion",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "_version",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "isDerivativeContractManagementActive",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_active",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dapp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			}
		],
		"name": "isKnownRoleByDappInternal",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_isKnownRoleByDapp",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "listContractsForDapp",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "_contractNames",
				"type": "string[]"
			},
			{
				"internalType": "address[]",
				"name": "_contracts",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			}
		],
		"name": "listContractsForRoleForDapp",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "_contractNames",
				"type": "string[]"
			},
			{
				"internalType": "address[]",
				"name": "_contractAddresses",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "listDapps",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "_dappList",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "_contractAddress",
				"type": "address"
			}
		],
		"name": "listFunctionsForRoleForContractForDapp",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "_functions",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "listRolesForDapp",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "_dappRoleList",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			}
		],
		"name": "listUsersForRole",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "_userAddresses",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			}
		],
		"name": "listUsersForRoleInternal",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "_userAddresses",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_contractAddresses",
				"type": "address[]"
			}
		],
		"name": "removeContractsForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_contracts",
				"type": "address[]"
			}
		],
		"name": "removeContractsForRoleForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "removeDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			}
		],
		"name": "removeDerivativeContractManagementForDApp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "_contract",
				"type": "address"
			},
			{
				"internalType": "string[]",
				"name": "_functions",
				"type": "string[]"
			}
		],
		"name": "removeFunctionForRoleForContractForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "_roleNames",
				"type": "string[]"
			}
		],
		"name": "removeRolesForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_dApp",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_role",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "_userAddresses",
				"type": "address[]"
			}
		],
		"name": "removeUserAddressesForRoleForDapp",
		"outputs": [
			{
				"internalType": "bool",
				"name": "_removed",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]