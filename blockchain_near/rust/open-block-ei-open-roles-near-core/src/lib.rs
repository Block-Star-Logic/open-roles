#![allow(dead_code)]
#![allow(unused_imports)]
//! SPDX-License-Identifier: APACHE 2.0 
//!
//! # OpenRoles crate for NEAR blockchain 
//! 
//! <br/> @author : Block Star Logic 
//! <br/> @coder : T Ushewokunze 
//! <br/> @license :  Apache 2.0 
//!
//! <br/> The **obei_or_near_core** crate contains the functionality to enable remote governance of function level access for smart contracts built on the NEAR blockchain.
//! <br/>
//! <br/> The **OpenRolesContract** is the core functional struct of this crate. It enables the independent creation of **'ParticipantList's** the registration of **'DependentContract's** to be 
//! placed under management and the assignment of **'ParticipantLists'** to **'DependentContracts'**.
//! <br/>
//! <br/> **'ParticipantList's** hold the participants to be either **'allowed'** or **'barred'** access to a given function on a given smart contract.
//! <br/>
//! <br/> **'DependentContact's** are the contracts for the dApp under governance of the **'OpenRolesContract'** 
//! <br/>
//! <br/> As the **OpenRolesContract** is deployed separately from the main **'functional contract'** the access scheme can be shared and retained across deployments and migrations, without altering the governance model
//! 
//! # Integration 
//! To integrate Open Roles into a dApp contract you need to 'use' **[\\or_traits::TOpenRoles]** and implement this where ever needed in your dApp contract as follows:
//! <br/> **[ext_open_roles::is_allowed ( near_account_id, registered_contract_name, contract_operation, signer_account_id, no_deposit, base_gas_fee );]**  
//! <br/> A Promise will be returned from the **OpenRolesContract** containing a **'bool'** as per the function definition
//!
mod tests;
mod or_structs;

use std::collections::{HashMap, HashSet};
use chrono::{Utc};
use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen};
use or_structs::{AssignmentAddress, DependentContract, ParticipantList};

near_sdk::setup_alloc!();

#[near_bindgen]
#[derive( serde::Serialize, BorshDeserialize, BorshSerialize, Default)]
struct OpenRoles{
	
	role_administrator : String, //administers all the accounts 
	
	id : String, // name of this 

	contract_by_contract_name_by_contract_account_id : HashMap<String, HashMap<String, or_structs::DependentContract>>, // main data store
	
	lists :HashMap<String, or_structs::ParticipantList>, // participant lists 
	
	operation_assignment_address_by_list : HashMap<String, HashSet<or_structs::AssignmentAddress>>, // view of list operation assignments 

	list_names : HashSet<String>, // participant list names 

	affirmative : i32, // affirmative value

	negative : i32, // negative value 

}

#[near_bindgen]
impl OpenRoles{
	
	/// Returns the code version of this OpenRoles instance 
	/// # Return Value 
	/// This function returns:
	/// **String** with code version 
	pub fn get_version(&self) -> String {
		"0.1.1".to_string()
	}
	
	/// Returns the id of this instance which was set on creation 
	/// # Return Value 
	/// This function returns :
	/// **String** with id as set by the administrator 
	pub fn get_id(&self) -> String {
		self.id.to_string()
	}

	/// Checks whether the given on chain **'user_account_id'**  is allowed to access the stated operation (function)
	/// <br/> This operation provides the implementation for **[\or_structs::TOpenRoles]**
	/// # Return Value 
	/// This function returns: 
	///  **'i32'** : value equal to **self.affirmative**  if and only if the user is listed as allowed to access the operation (default = 1)	
	pub fn is_allowed(&self, contract_account_id : String, contract_name : String, operation : String, user_account_id : String) -> i32 {
		if self.is_registered(contract_account_id.clone(), contract_name.clone()){
			let  list_name = self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().get(&contract_name).unwrap().list_name_by_operation.get(&operation).unwrap();
			let plist = self.lists.get(list_name).unwrap();
	
			if plist.status.as_bytes() != "DELETED".to_string().as_bytes() && plist.account_ids.contains(&user_account_id){
				return self.affirmative
			}
			return self.negative
		}
		else {
			panic!(" CONTRACT : {} NOT REGISTERED FOR ACCOUNT : {} ", contract_account_id, contract_name)
		}
	}

	/// Checks whether the given on chain **'user_account_id'**  is barred from access the stated operation (function)
	/// <br/> This operation provides the implementation for **[\or_structs::TOpenRoles]**
	/// # Return Value 
	/// This function returns: 
	///  **'i32'** : value equal to **self.affirmative** if and only if the user is listed as barred to access the operation (default = 1)	 
	pub fn is_barred(&self, contract_account_id : String, contract_name :String, operation : String, user_account_id : String) -> i32 {
		if self.is_registered(contract_account_id.clone(), contract_name.clone()){
			let  list_name = self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().get(&contract_name).unwrap().list_name_by_operation.get(&operation).unwrap();		
			let plist = self.lists.get(list_name).unwrap();

			if plist.status.as_bytes() != "DELETED".to_string().as_bytes() && plist.account_ids.contains(&user_account_id){
				 return self.affirmative
			} 		
			return self.negative
		}
		else {
			panic!(" CONTRACT : {} NOT REGISTERED FOR ACCOUNT : {} ", contract_account_id, contract_name)
		}
	}
	
	/// Checks whether the given **DependentContract** is registered under the given **concract_account_id** 
	/// <br/> This operation provides the implementation for **[\or_structs::TOpenRoles]**
	/// # Return Value 
	/// This function returns: 
	///  **'bool'** : **true** if and only if the contract is registered according to the given details  
	pub fn is_registered(&self, contract_account_id : String, contract_name : String) -> bool {
		self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().contains_key(&contract_name)
	}
	
	pub fn view_list_assignments(&self, list_name : String) -> &HashSet<AssignmentAddress> {
		self.operation_assignment_address_by_list.get(&list_name).unwrap()
	}

	/// Assigns the given **list** to the given operation on the given contract deployed at the given NEAR account id
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns: *String* otherwise panics  
	pub fn assign_list_to_operation(&mut self, contract_account_id : String, contract_name : String, operation : String, list_name : String) -> String {
		self.administrator_only ();
		
		let assignment_address = AssignmentAddress {
								deployment_account_id: contract_account_id.clone(), 
								contract_name : contract_name.clone(), 
								operation : operation.clone(),
							};

		let contract = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap().get_mut(&contract_name).unwrap();
				
		contract.assign_list_name_to_operation(operation.clone(), list_name.clone());
		
		if self.operation_assignment_address_by_list.contains_key(&list_name) {

		}
		else {
			let mut ops = HashSet::<AssignmentAddress>::new(); 
			ops.insert(assignment_address);			
			self.operation_assignment_address_by_list.insert(list_name.clone(), ops);
		}

		format!("LIST {} ASSIGNED", list_name).to_string()
	}
		
	/// Removes the given **list** from the given operation on the given contract deployed on the given NEAR account id 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	// This function returns *String* otherwise panics 
	pub fn remove_list_from_operation(&mut self, contract_account_id : String, contract_name : String, operation : String) -> String {
		self.administrator_only ();
		
		let assignment_address = or_structs::AssignmentAddress {
			deployment_account_id: contract_account_id.clone(), 
			contract_name :contract_name.clone(), 
			operation : operation.clone(),
		};

		let contract = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap().get_mut(&contract_name).unwrap();
		
		let list_name = contract.de_assign_list_name_from_operation(operation);
		
		self.operation_assignment_address_by_list.get_mut(&list_name).unwrap().remove(&assignment_address);

		format!("LIST {} REMOVED", &list_name).to_string()						
	}

	
	/// Creates the given **list** with **ACTIVE** status 
	/// <br/> *Administrator Only function* 
	/// # Return Value 
	/// This function returns *String* otherwise panics 
	pub fn create_list(&mut self, list_name : String, list_type : String) -> String {
		self.administrator_only ();
		let list = ParticipantList {
							name : list_name.clone(), 
							list_type, 
							account_ids : HashSet::<String>::new(),
							status : "ACTIVE".to_string(),
						};
		self.lists.insert(list_name.clone(), list);
		self.list_names.insert(list_name.clone());
		format!("LIST {} CREATED", list_name).to_string()
	}

	/// Deletes the given **list** from those available by setting the list status to **DELETED**
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  
	pub fn delete_list(&mut self, list_name : String) -> String {
		self.administrator_only ();
		
		let plist = self.lists.get_mut(&list_name).unwrap(); 
		plist.status = "DELETED".to_string();

		self.list_names.remove(&plist.name);

		format!("LIST {} DELETED.",plist.name).to_string()
	}
    
	/// Adds a NEAR blockchain user_account_id to the given **list_name** from those available 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  
	pub fn add_account_id_to_list(&mut self, user_account_id : String, list_name : String) -> String {
		self.administrator_only ();
		let plist = self.lists.get_mut(&list_name).unwrap();
		
		OpenRoles::check_status( plist.status.to_string(), "ACTIVE".to_string());
		
		plist.account_ids.insert(user_account_id.clone());
		
		format!("ACCOUNT {} ADDED.",user_account_id).to_string()
	}    
	
	/// Removes the given NEAR blockchain user_account_id from the given **list** 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  	
	pub fn remove_account_from_list(&mut self, user_account_id : String, list_name : String) -> String {
		self.administrator_only ();
		let plist = self.lists.get_mut(&list_name).unwrap(); 

		OpenRoles::check_status( plist.status.to_string(), "ACTIVE".to_string());

		plist.account_ids.remove(&user_account_id);
		
		format!("ACCOUNT {} REMOVED.",user_account_id).to_string()
	}	
	
	/// Registers the given contract as deployed on the given **contract_account_id** with the given operations 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  
	pub fn register_contract(&mut self, contract_account_id : String, contract_name : String, ops : Vec<String>) -> String {
		self.administrator_only ();
		let mut u_ops = HashSet::<String>::new();
		for o in ops { 
			u_ops.insert(o);
		}
		let contract = DependentContract{
								name : contract_name, 
								account_id : contract_account_id, 
								operations : u_ops, 
								list_name_by_operation : HashMap::<String, String>::new(),
							 };
		let msg = format!("CONTRACT {} REGISTERED", &contract.view_name());
		
		if self.contract_by_contract_name_by_contract_account_id.contains_key(&contract.view_account_id()) {
			
			let contracts  = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract.view_account_id()).unwrap();
			
			if contracts.contains_key(&contract.view_name()) {
				panic!("Contract {} already registered. De-register and re-register to change.", &contract.view_name())
			}
			else {
				let c_name = contract.view_name().clone(); 
				contracts.insert(c_name, contract);
			}			
		}
		else {
			
			let mut cs = HashMap::<String, DependentContract>::new();
			
			let c_n = contract.view_name();
			let c_a_id = contract.view_account_id();
			
			cs.insert(c_n, contract);
			self.contract_by_contract_name_by_contract_account_id.insert(c_a_id, cs);
		}
		msg
	}	
	
	/// Deregisters the given NEAR **contract** deployed at the given NEAR blockchain **contract_account_id**
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  
	pub fn deregister_contract(&mut self, contract_account_id : String, contract_name : String) -> String {
		self.administrator_only ();
		let contracts = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap();
		contracts.remove(&contract_name); 
		let msg = format!("CONTRACT {} DE-REGISTERED", contract_name);
		msg
	}		
	
	/// Provides a list of list_names currently held by this instance. This will include names of **DELETED** lists 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns *String* otherwise panics  
	pub fn view_list_names(&self) -> HashSet<String>{
		self.administrator_only();
		self.list_names.clone()
	}

		
	/// Provides a view of the list consisting of the name, type, NEAR account ids held and status of the list 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns a tuple otherwise panics 
	pub fn view_list(&self, list_name : String) -> (/*name*/ String,  /*type*/ String, /*ids*/ HashSet<String>, /*status*/ String) { 
		self.administrator_only();
		let plist = self.lists.get(&list_name).unwrap();
		plist.get_tuple()
	}
   	

	/// Provides a view of the currently assigned role administrator for this instance 
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns a *String* otherwise panics
	pub fn view_role_administrator(&self)-> String{
		self.role_administrator.clone()
	}

	
	/// Sets the role administrator for this instance MUST be set after deployment
	/// <br/> *Administrator Only function*
	/// # Return Value 
	/// This function returns a *String* otherwise panics
	pub fn set_role_administrator(&mut self, account_id : String) -> bool { 
		self.administrator_only();
		self.role_administrator = account_id; 		
		true
	}	

	/// Sets the id for this instance MUST be set after deployment
	/// <br/> *Administrator Only function* 
	/// # Return Value 
	/// *true* if the instance 'id' is set
	pub fn set_instance_id(&mut self, instance_id : String) -> bool { 
		self.administrator_only();
		self.id = instance_id; 
		true 
	}

	/// Sets the affirmative code for this instance MUST be set after deployment
	/// <br/> *Administrator Only function* 
	/// # Return Value 
	/// This function rturns a *String* message
	pub fn set_affirmative_code(&mut self, affirmative : i32) -> String {
		self.administrator_only();
		self.affirmative = affirmative; 
		format!(" AFFIRMATIVE CODE : {} ", affirmative).to_string()
	}

	/// Sets the negative code for this instance MUST be set after deployment
	/// <br/> *Administrator Only function* 
	/// # Return Value 
	/// This function rturns a *String* message
	pub fn set_negative_code(&mut self, negative : i32) -> String {
		self.administrator_only();
		self.negative = negative;
		format!(" NEGATIVE CODE : {} ", negative).to_string()
	}

	/// Creates an instance of the OpenRoles contract
	/// # Return Value 
	/// This function creates an instance with the given configuration
	#[init]
	pub fn new( role_administrator :String, instance_id : String, affirmative_code : i32, negative_code : i32 ) -> Self {
		Self {
			role_administrator,
			id : instance_id,
			contract_by_contract_name_by_contract_account_id : HashMap::<String, HashMap<String, DependentContract>>::new(),
			lists : HashMap::<String, or_structs::ParticipantList>::new(),
			list_names : HashSet::<String>::new(),
			operation_assignment_address_by_list : HashMap::<String, HashSet<AssignmentAddress>>::new(),
			affirmative : affirmative_code, 
			negative : negative_code,
		}
	}	

	/// Call the new( function )
    pub fn default() -> Self { 
        panic!("OPEN ROLES REQUIRES INITIALISATION ON DEPLOYMENT")
    }

	fn check_status( base : String, required : String) {
		if base.as_bytes() == required.as_bytes() {
			return; 
		}
		panic!("INVALID STATUS REQUIRED : {}, PRESENTED : {} " ,required, base );
	}
	 
	fn administrator_only(&self) -> bool {
		if self.role_administrator == "" {
			panic!( "ADMINISTRATOR NOT SET");
		}

		let caller = env::signer_account_id().to_string();
		if caller.as_bytes() == self.role_administrator.to_string().as_bytes() {
			return true; 	
		}	
		panic!( "ROLE ADMINISTRATOR ONLY - CALLER {} ", caller);
	
	}

}