# Open Roles NEAR Blockchain Administrators Guide

This guide has been prepared for administrators working with Open Roles on the NEAR Blockchain. It describes how to typically deploy and configure Open Roles on the NEAR Blockchain. This guide has been prepared for “no-code” administration of Open Roles. It uses the NEAR CLI to interface with the NEAR Blockchain, the installation instructions for which can be found here:
https://docs.near.org/docs/tools/near-cli

An administration wallet will need to be created for your deployment and instructions of how to create this can be found here:
https://docs.near.org/docs/tools/near-wallet 

All administration transactions can be monitored using the NEAR Blockchain block explorer which can be found here:
 https://docs.near.org/docs/tools/near-explorer 

It is recommended that a testnet instance of Open Roles be deployed to ensure your Role Matrix is behaving as you expect, both independently and in any dependent dApps.

This guide assumes the following:
* There is a separate dev team responsible for coding your dApps 
* The Role Matrix has been prepared by at least one person from business operations, dev/product and admin (for more information on how to prepare a Role Matrix see Open Roles Business Guide)

## NEAR Blockchain Deployment 
To utilise the Open Roles Project it has to be deployed onto the NEAR blockchain. The procedure for deploying onto the different networks i.e. mainnet or testnet only differs in that the network configuration needs to be modified to point to the correct NEAR Blockchain network.

**NOTE: the NEAR Blockchain accounts that you use must have funds available to execute ANY admin operation.** 

## Instructions
1. Download the latest / recommended release from github here:
https://github.com/Block-Star-Logic/open-roles 
2. Open a command prompt or terminal window
3. Log in to your near account using:<br/>
``` > near login ``` 
4. Deploy this release using the following command:<br/>
``` > near deploy --accountId {deploy-account-id} --wasmFile {path-to-your-release-download}/obei_or_near_core_v{version}.wasm ```
5. Test your release is deployed with the following command:<br/>
``` > near call {deploy-account-id} get_version --account_id {admin-account-id} ```
6. This should return the version number of the release you have just deployed
7. You will then need to run the following command:<br/>
``` > near call {deploy-account-id} view_role_administrator --account_id {admin-account-id} ```
This should reflect the admin account that is configured to manage the newly deployed Open Roles Contract instance

## Configuration 
The following describes how to configure a newly deployed instance of Open Roles. For maintenance of an existing deployment of Open Roles see Maintenance Tasks. 
<br/>
<br/>
The configuration tasks assume the following:
* You are logged in with a NEAR Blockchain account set to administer your instance. 

### Register Contract
1. To register a dApp Contract with Open Roles the following will need to execute the following command:<br/>
``` > near call {deploy-account-id} register_contract {“contract_account_id” : “{contract_deploy_account_id}”, “contract_name” : “{contract_name}”, “ops” : “[{list_of_contract_functions}]" } --account_id {admin-account} ```
2. Check that your contract is registered by executing this command:<br/>
```> near call {deploy-account-id} is_registered {“contract_account_id” : “{contract_deploy_account_id}”, “contract_name” : “{contract_name}” --account_id {admin-account}```
3. Once you have registered a contract you will need to create or assign access control lists to the various operations of the contract as per your Role Matrix. For list creation see below, for list assignment see Assign To Operation

## Build List
The following steps will guide you in how to create a list, assign an account_id to that list, assign that list to a contract function and test your configuration:
1. To create a list you will need to execute the following command:<br/>
``` > near call {deploy-account-id} create_list {“list_name” : “{name_of_your_chosen_list}, “list_type” : {“BARRED”_or_”ALLOWED”}} --account_id {admin-account} ```
2. To add a user to the list you will need to execute the following command:<br/>
``` > near call {deploy-account-id} add_account_id_to_list {“account_id” : “account_id_to_add”} --account_id {admin-account} ```
3. To assign a list to a contract operation execute the following command:<br/>
``` > near call {deploy-account-id} assign_list_to_operation {contract_account_id : {contract_account_id}, contract_name : {contract_name}, operation : {name_of_operation}, list_name : {name_of_list}} ```
4. To test your new configuration you will need to execute the following command:<br/>
``` > near call {deploy-account-id} is_allowed {“contract_account_id” : “{contract_account_id}”, “contract_name” : “{registered_name_of_contract}”, “operation” : {name_of_contract_operation}, “user_account_id” : {account_id_of_target_user} } --account_id {admin-account} ```

## Maintenance Tasks 
The following are the maintenance tasks necessary to administer your Open Roles Contract deployment:
Open Roles NEAR Blockchain Administrators Guide
