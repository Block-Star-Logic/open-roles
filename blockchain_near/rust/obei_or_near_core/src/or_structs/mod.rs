use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{near_bindgen,};
use near_sdk::collections::{UnorderedSet,};
use std::collections::{HashSet,};
use std::collections::HashMap;

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
pub struct ParticipantList { 
	pub name : String, 
	pub list_type : String,
	pub account_ids : HashSet<String>, 
	pub status : String, 
}

impl ParticipantList {

	pub fn get_tuple(&self) -> (String, String, HashSet<String>, String){
		(self.name.clone(), self.list_type.clone(), self.account_ids.clone(), self.status.clone())
	}
}

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
pub struct DependentContract {
	pub name : String, 
	pub account_id : String, 
	pub operations : Vec<String>,
	pub list_name_by_operation : HashMap<String, String>, 
}

impl DependentContract {
	
	pub fn view_name(&self) -> String {
		self.name.clone()
	}
	
	pub fn view_account_id(&self) -> String {
		self.account_id.clone()
	}
	
	pub fn view_operations(&self) -> Vec<String> { 
		self.operations.clone()
	}
	
	pub fn view_list_name(&self, operation : String) -> String {
		self.list_name_by_operation.get(&operation).unwrap().to_string()
	}
	
	pub fn assign_list_name_to_operation(&mut self, operation : String, list : String) -> bool { 
		if self.operations.contains(&operation) {
			self.list_name_by_operation.insert(operation, list); 
			return true
		}
		false
	}
	
	pub fn de_assign_list_name_from_operation(&mut self, operation : String,) -> String { 
		if self.operations.contains(&operation) {
			let list_name = self.list_name_by_operation.remove(&operation).unwrap();
			return list_name  			
		}
		"".to_string()
	}	
}

#[near_bindgen]
#[derive(Default,Hash, PartialOrd, Clone, PartialEq, Eq, BorshDeserialize, BorshSerialize)]
pub struct AssignmentAddress  {
	pub deployment_account_id : String,
	pub contract_name : String,
	pub operation : String, 
}


