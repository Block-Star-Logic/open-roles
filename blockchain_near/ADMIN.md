# Open Roles NEAR Blockchain Administrators Guide

**For further support join our <a href="https://rebrand.ly/obei_or_git">Discord</a> on the #admin-support channel**

This guide has been prepared for administrators working with Open Roles on the NEAR Blockchain. It describes how to typically deploy and configure Open Roles on the NEAR Blockchain. This guide has been prepared for “no-code” administration of Open Roles. It uses the NEAR CLI to interface with the NEAR Blockchain, the installation instructions for which can be found here:
https://docs.near.org/docs/tools/near-cli

An administration wallet will need to be created for your deployment and instructions of how to create this can be found here:
https://docs.near.org/docs/tools/near-wallet 

All administration transactions can be monitored using the NEAR Blockchain block explorer which can be found here:
 https://docs.near.org/docs/tools/near-explorer 

It is recommended that a testnet instance of Open Roles be deployed to ensure your Role Matrix is behaving as you expect, both independently and in any dependent dApps.

This guide assumes the following:
* There is a separate dev team responsible for coding your dApps 
* The Role Matrix has been prepared by at least one person from business operations, dev/product and admin (for more information on how to prepare a Role Matrix see <a href="https://github.com/Block-Star-Logic/open-roles/tree/main/business/README.md">Open Roles Business Guide </a>)

## NEAR Blockchain Deployment 
To utilise the Open Roles Project it has to be deployed onto the NEAR blockchain. The procedure for deploying onto the different networks i.e. mainnet or testnet only differs in that the network configuration needs to be modified to point to the correct NEAR Blockchain network.

**NOTE:** 
* The NEAR Blockchain accounts that you use must have funds available to execute ANY admin operation.
* For all command line arguments in JSON you must escape with '\\' to ensure your "" quotes are preserved. 

## Instructions
1. Download the latest / recommended release from github here:
https://github.com/Block-Star-Logic/open-roles 
2. Open a command prompt or terminal window
3. Log in to your near account using:<br/>
``` > near login ``` 
4. Deploy this release using the following command:<br/>
``` > near deploy --accountId ${deploy-account-id} --wasmFile ${path-to-your-release-download}/open-block-ei-open-roles-near-core.wasm ```
5. Test your release is deployed with the following command:<br/>
``` > near call ${deploy-account-id} get_version --account_id ${admin-account-id} ```<br/>
   This should return the version number of the release you have just deployed
6. You will then need to run the following command:<br/>
``` > near call ${deploy-account-id} view_role_administrator --account_id ${admin-account-id} ```<br/>
7. You will then need to run the following command:<br/>
``` > near call ${deploy-account-id} set_role_administrator {"account_id" : "${new_admin_account}"} --account_id ${admin-account-id} ```<br/>
8. You will then need to complete your deployment by running the following command:<br/>
``` > near call ${deploy-account-id} set_instance_id {"instance_id" : "${instance-id}"} --account_id ${admin-account-id} ```<br/>



## Configuration 
The following describes how to configure a newly deployed instance of Open Roles. For maintenance of an existing deployment of Open Roles see Maintenance Tasks. 
<br/>
<br/>
The configuration tasks assume the following:
* You are logged in with a NEAR Blockchain account set to administer your instance. 

### Register Contract
1. To register a dApp Contract with Open Roles the following will need to execute the following command:<br/>
``` > near call ${deploy-account-id} register_contract { "contract_account_id" : “${contract_deploy_account_id}”, "contract_name" : “${contract_name}”, ops : ["${list_of_contract_functions}"] } --account_id ${admin-account} ```
2. Check that your contract is registered by executing this command:<br/>
```> near call ${deploy-account-id} is_registered { "contract_account_id" : “${contract_deploy_account_id}”, "contract_name" : “${contract_name}"} --account_id ${admin-account}```
3. Once you have registered a contract you will need to create or assign access control lists to the various operations of the contract as per your Role Matrix. For list creation see below, for list assignment see <a href="#alto">Assign List To Operation</a>

## Build List
The following steps will guide you in how to create a list, assign an account_id to that list, assign that list to a contract function and test your configuration, (NOTE: be sure to "escape" the quotes):
1. To create a list you will need to execute the following command:<br/>
``` > near call ${deploy-account-id} create_list { "list_name" : “${name_of_your_chosen_list}", "list_type" : ${“BARRED”_or_”ALLOWED”}} --account_id ${admin-account} ```
2. To add a user to the list you will need to execute the following command:<br/>
``` > near call ${deploy-account-id} add_account_id_to_list { "account_id" : “${account_id_to_add}”} --account_id ${admin-account} ```
3. To assign a list to a contract operation execute the following command:<br/>
``` > near call {deploy-account-id} assign_list_to_operation { "contract_account_id" : "${contract_account_id}", "contract_name" : "${contract_name}", "operation" : "${name_of_operation}", "list_name" : "${name_of_list}"} ```
4. To test your new configuration you will need to execute the following command:<br/>
``` > near call ${deploy-account-id} is_allowed { "contract_account_id" : “${contract_account_id}”, "contract_name" : “${registered_name_of_contract}”, "operation" : "${name_of_contract_operation}", "user_account_id" : "${account_id_of_target_user}" } --account_id ${admin-account} ```

## Maintenance Tasks 
The following are the maintenance tasks necessary to administer your Open Roles Contract deployment:

### List Management
List Management is the core of Open Roles. There are two types of list **ALLOWED** and **BARRED**. 
* **ALLOWED** lists are non-permissive i.e. only individuals on the list will be **allowed** to accesss the governed service. 
* **BARRED** lists are permissive i.e. all individuals will be allowed to access the governed service **except** those on the list
It is recommended that you check for conflicts in your role matrix 

#### Create List 
To create a list you execute the following command: <br/>
``` > near call ${deploy-account-id} create_list {"list_name" : “${name_of_your_chosen_list}, "list_type" : ${“BARRED”_or_”ALLOWED”}} --account_id ${admin-account} ``` <br/>
**NOTE:** 
* Administrator only 

#### View List 

##### View Name
To view the names of the available lists you execute the following command: <br/>
``` > near call ${deploy-account-id} view_list_names --account_id ${admin-account-id} ``` <br/> <br/>
This will return to you the following data:
* names - names of all the lists configured in your instance 

**NOTE:** 
* Anyone can view the names of the lists on your Open Roles instance 

##### View Contents
To view the contents of a list you execute the following command: <br/>
``` > near call ${deploy-account-id} view_list ${ "list_name" : "${name_of_your_chosen_list}"} --account_id ${admin-account-id} ``` <br/> <br/>
This will return to you the following data:
* name - name of the list
* type - type of the list i.e. **BARRED** or **ALLOWED**
* ids - list of ids on the list 
* status - status of the list 

**NOTE:** 
* Anyone can view the contents of your list 

#### Assign List To Operation <span id="alto"></span>

To assign a list to a given operation execute the following command: <br/>
``` > near call ${deploy-account-id} assign_list_to_operation {"contract_account_id" : "${contract_account_id}", "contract_name" : "${contract_name}", "operation" : "${name_of_operation}", "list_name" : "${name_of_list}"} --account_id ${admin-account-id}```<br/>

**NOTE:** 
* Administrator only 
* An operation can only have one list assigned to it. A call to **assign_list_to_operation** for the same operation will result in the latest list being the assignment

#### Remove List from Operation

To remove a list from a given operation execute the following command: <br/>
``` > near call ${deploy-account-id} remove_list_from_operation {"contract_account_id" : "${contract_account_id}", "contract_name" : "${contract_name}", "operation" : "${name_of_operation}"} --account_id ${admin-account-id} ```<br/>

**NOTE:**
* Administrator only 
* This will leave the list operation without a list therefore any dependent dApp calls to the operation will **fail** 

#### Delete List 

To delete a list execute the following command:<br/>
``` > near call ${deploy-account-id} delete_list {"list_name" : "${name_of_list}"} --account_id ${admin-account-id} ``` <br/>

**NOTE:** 
* Administrator only 
* This will set the status of the list to **DELETED**. 
* Any calls to dependent calls to **fail**.

### User Management
To manage user (i.e. account id) access downstream, user account ids need to be added to lists i.e. ALLOWED or BARRED. A user will be granted or barred from accessing any dApp operations that the list is assigned to. 

#### Add User to List
To add a user to a list execute this command:<br/>
``` > near call ${deploy-account-id} add_account_id_to_list ( "user_account_id" : "${account_id_of_user}" , "list_name" : "${name_of_list}") --account_id ${admin-account-id} ```<br/>

**NOTE:** 
* Administrator only 

#### Delete User from List 
To delete a user from a list execute this command:<br/>
``` > near call ${deploy-account-id} remove_account_from_list {"user_account_id" : "${account_id_of_user}" , "list_name" : "${name_of_list}"} --account_id ${admin-account-id} ```<br/>

**NOTE:** 
* Administrator only 

### Contract Management 
This section describes the tasks that need to be executed to manage Contracts in an Open Roles instance 
	
#### Register a Contract
To register a contract with an Open Roles instance execute this command: <br/>
``` > near call ${deploy-account-id} register_contract {“contract_account_id” : “${contract_deploy_account_id}”, “contract_name” : “${contract_name}”, “ops” : ["${list_of_contract_functions}"] } --account_id ${admin-account} ```<br/>

**NOTE:** 
* Administrator only 

#### De-register a Contract 
To de-register a contract with an Open Roles instance execute this command: <br/>
``` > near call ${deploy-account-id} register_contract {“contract_account_id” : “${contract_deploy_account_id}”, “contract_name” : “${contract_name}”} --account_id ${admin-account-id}```<br/>

**NOTE:** 
* Administrator only 

#### Migrate a Contract
To migrate Open Roles the dependent contracts have to be configured to point to the new deployed instance.

#### Check Contract Registration 
To check whether a contract is registered with an instance of Open Roles execute this command: <br/>
``` > near call ${deploy-account-id} is_registered  {"contract_account_id" : “${contract_deploy_account_id}”, "contract_name" : “${contract_name}”} --account_id ${admin-account-id}```<br/>

This will return **true** if the ccontract is registered 

**NOTE:** 
* Anyone can check if a contract is registered with your Open Roles instance

#### View List Assignments 
To view the assignments of lists to contract operations execute this command:<br/>
``` > near call ${deploy-account-id} view_list_assignments {"list_name" : "${name_of_list}"} --account_id ${admin-account-id} ```<br/>

this will return a list of **objects** 

**NOTE:**
* Anyone can check if the list assignments in your Open Roles instance

### Open Roles Instance Management 
The Open Roles instance supports the following instance administration tasks 

#### Check Open Roles Deployment Version
To check the version of the deployed Open Roles instance execute this command:<br/>
``` > near call ${deploy-account-id} get_version --account_id ${admin-account-id} ```<br/>

This will return the version of the instance 

**NOTE:**
* Anyone can check the version of your Open Roles instance 

#### View Administrator 
To view the account that administers this Open Roles instance execute this command:<br/> 
``` > near call ${deploy-account-id} view_role_administrator --account_id ${admin-account-id} ```<br/>

**NOTE:**
* Anyone can check the version of your Open Roles instance 

#### Change Administrator <span id="change administrator"></span>
To change the account that administers this Open Roles instance execute this command:<br/>
``` > near call ${deploy-account-id} set_role_administrator {"account_id" : "${new_admin_account}"} --account_id ${admin-account-id} ```<br/>
**NOTE:** 
* Administrator only 
	
	
#### Change Instance Id <span id="change instance id"></span>
To change the id for the deployed instance of Open Roles instance execute this command:<br/>
``` > near call ${deploy-account-id} set_instance_id {"instance_id" : "${new_instance_id}"} --account_id ${admin-account-id} ```<br/>	
**NOTE:** 
* Administrator only 

#### Change Affirmative Code 
To change the *affirmative code* for the deployed instance of Open Roles instance execute this command:<br/>
``` > near call ${deploy-account-id} set_instance_id {"affirmative" : "${number}"} --account_id ${admin-account-id} ```<br/>
**NOTE:** 
* Administrator only 
* **WARNING** changing the Affirmative Code can have serious consequences on any dependent in LIVE dapps

	
#### Change Instance Id <span id="change instance id"></span>
To change the *negative code* for the deployed instance of Open Roles instance execute this command:<br/>
``` > near call ${deploy-account-id} set_instance_id {"instance_id" : "${instance-id}"} --account_id ${admin-account-id} ```<br/>
**NOTE:** 
* Administrator only 
* **WARNING** changing the Negative Code can have serious consequences on any dependent in LIVE dapps


#### Migrate Open Roles 
To migrate Open Roles the dependent contracts have to be configured to point to the new deployed instance.

**For further support join our <a href="https://rebrand.ly/obei_or_git">Discord</a> on the #admin-support channel**
