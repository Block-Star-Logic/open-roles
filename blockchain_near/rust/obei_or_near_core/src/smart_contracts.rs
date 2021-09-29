use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{near_bindgen,};
use near_sdk::collections::{LookupMap,};
use std::collections::HashMap;

use crate::participant_lists::PList;

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
pub struct SContract {
	pub name : String, 
	pub account_id : String, 
	pub operations : Vec<String>,
	pub list_name_by_operation : HashMap<String, String>, 
}

impl SContract {
	
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
		
		pub fn de_assign_list_name_from_operation(&mut self, operation : String,) -> bool { 
			if self.operations.contains(&operation) {
				self.list_name_by_operation.remove(&operation); 
				return true
			}
			false
		}
	
}