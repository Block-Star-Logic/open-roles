use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{near_bindgen,};
use near_sdk::collections::{UnorderedSet,};
use std::collections::{HashSet,};

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
pub struct PList { 
	pub name : String, 
	pub list_type : String,
	pub account_ids : HashSet<String>, 
	pub status : String, 
}

impl PList {

	pub fn get_tuple(&self) -> (String, String, HashSet<String>, String){
		(self.name.clone(), self.list_type.clone(), self.account_ids.clone(), self.status.clone())
	}
}