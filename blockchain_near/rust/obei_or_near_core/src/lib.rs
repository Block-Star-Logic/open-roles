use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen,};
use near_sdk::collections::{UnorderedSet, LookupMap, Vector,};
use std::collections::{HashMap, HashSet,};
use std::convert::TryFrom;


near_sdk::setup_alloc!();


mod participant_lists; 
mod smart_contracts;
//mod enums;

#[near_bindgen]
#[derive(Default, borsh::BorshDeserialize, borsh::BorshSerialize)]
struct OpenRoles{
	role_administrator : String, 
	
	contract_by_contract_name_by_contract_account_id : HashMap<String, HashMap<String, smart_contracts::SContract>>,
	
	lists : HashMap<String, participant_lists::PList>,
	
	list_names : Vec<String>,
}

#[near_bindgen]
impl OpenRoles{
	
	pub fn is_allowed(&self, contract_account_id : String, contract_name : String, operation : String, user_account_id : String) -> bool {
		let  list_name = self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().get(&contract_name).unwrap().list_name_by_operation.get(&operation).unwrap();
		let plist = self.lists.get(list_name).unwrap();
		if plist.status.as_bytes() != "DELETED".to_string().as_bytes() {
			return plist.account_ids.contains(&user_account_id)
		}
		false
	}

	pub fn is_barred(&self, contract_account_id : String, contract_name :String, operation : String, user_account_id : String) -> bool {
		let  list_name = self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().get(&contract_name).unwrap().list_name_by_operation.get(&operation).unwrap();		
		let plist = self.lists.get(list_name).unwrap();
		if plist.status.as_bytes() != "DELETED".to_string().as_bytes() {
			return plist.account_ids.contains(&user_account_id)
		}
		false
	}
	
	pub fn is_registered(&self, contract_account_id : String, contract_name : String) -> bool {
		self.contract_by_contract_name_by_contract_account_id.get(&contract_account_id).unwrap().contains_key(&contract_name)
	}
	
	pub fn assign_list_to_operation(&mut self, contract_account_id : String, contract_name : String, operation : String, list_name : String) -> String {
		self.administrator_only ();
		
		let contract = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap().get_mut(&contract_name).unwrap();
				
		contract.assign_list_name_to_operation(operation, list_name);
		
		"LIST ASSIGNED".to_string()
	}

	pub fn remove_list_from_operation(&mut self, contract_account_id : String, contract_name : String, operation : String) -> String {
		self.administrator_only ();
		
		let contract = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap().get_mut(&contract_name).unwrap();
		
		contract.de_assign_list_name_from_operation(operation);
		
		"LIST REMOVED".to_string()
				
	}

	pub fn create_list(&mut self, list_name : String, list_type : String) -> String {
		self.administrator_only ();
		let list = participant_lists::PList {
							name : list_name.clone(), 
							list_type, 
							account_ids : HashSet::new(),
							status : "ACTIVE".to_string(),
						};
		self.lists.insert(list_name, list);
		"LIST CREATED".to_string()
	}

	pub fn delete_list(&mut self, list_name : String) -> String {
		self.administrator_only ();
		let plist = self.lists.get_mut(&list_name).unwrap(); 
		plist.status = "DELETED".to_string();
		
		"LIST DELETED".to_string()
	}

	pub fn add_account_id_to_list(&mut self, user_account_id : String, list_name : String) -> String {
		self.administrator_only ();
		let plist = self.lists.get_mut(&list_name).unwrap();

		plist.account_ids.insert(user_account_id);
		
		"ACCOUNT ADDED".to_string()
	}

	pub fn remove_account_from_list(&mut self, user_account_id : String, list_name : String) -> String {
		self.administrator_only ();
		let plist = self.lists.get_mut(&list_name).unwrap(); 

		plist.account_ids.remove(&user_account_id);
		
		"ACCOUNT REMOVED".to_string()
	}
	
	pub fn register_contract(&mut self, contract_account_id : String, contract_name : String, ops : Vec<String>) -> String {
		self.administrator_only ();
		let contract = smart_contracts::SContract{
								name : contract_name, 
								account_id : contract_account_id, 
								operations : ops, 
								list_name_by_operation : HashMap::new(),
							 };
		let msg = format!("CONTRACT {} REGISTERED", &contract.view_name());
		
		if self.contract_by_contract_name_by_contract_account_id.contains_key(&contract.view_account_id()) {
			
			let contracts : &mut HashMap<std::string::String, smart_contracts::SContract> = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract.view_account_id()).unwrap();
			
			if contracts.contains_key(&contract.view_name()) {
				panic!("Contract {} already registered. De-register and re-register to change.", &contract.view_name())
			}
			else {
				let c_name = contract.view_name().clone(); 
				contracts.insert(c_name, contract);
			}
			
		}
		else {
			
			let mut cs  : HashMap<std::string::String, smart_contracts::SContract> = HashMap::new();
			
			let c_n = contract.view_name();
			let c_a_id = contract.view_account_id();
			
			cs.insert(c_n, contract);
			self.contract_by_contract_name_by_contract_account_id.insert(c_a_id, cs);
		}
		msg
	}


	pub fn deregister_contract(&mut self, contract_account_id : String, contract_name : String) -> String {
		self.administrator_only ();
		let contracts : &mut HashMap<std::string::String, smart_contracts::SContract> = self.contract_by_contract_name_by_contract_account_id.get_mut(&contract_account_id).unwrap();
		contracts.remove(&contract_name); 
		let msg = format!("CONTRACT {} DE-REGISTERED", contract_name);
		msg
	}
	
	pub fn view_list_names(&self) -> Vec<String>{
		self.administrator_only();
		self.list_names.clone()
	}
	
	pub fn view_list(&self, list_name : String) -> (String, String, HashSet<String>, String) { 
		self.administrator_only();
		let plist = self.lists.get(&list_name).unwrap();
		plist.get_tuple()
	}
   	
	pub fn view_role_administrator(&self)-> String{
		self.role_administrator.clone()
	}
	
	pub fn set_role_administrator(&mut self, account_id : String) -> bool { 
		self.administrator_only();
		self.role_administrator = account_id; 
		true
	}

	fn administrator_only(&self) -> bool {
		let caller = near_sdk::env::current_account_id().to_string();
		if caller == self.role_administrator {
			panic!( "ROLE ADMINISTRATOR ONLY");
		}	
		true 
	}
}


#[cfg(test)]
mod tests {
    use super::*;
    use near_sdk::MockedBlockchain;
    use near_sdk::{testing_env, VMContext};

    // part of writing unit tests is setting up a mock context
    // in this example, this is only needed for env::log in the contract
    // this is also a useful list to peek at when wondering what's available in env::*
    fn get_context(input: Vec<u8>, is_view: bool) -> VMContext {
        VMContext {
            current_account_id: "or_admin.testnet".to_string(),
            signer_account_id: "or_signer.testnet".to_string(),
            signer_account_pk: vec![0, 1, 2],
            predecessor_account_id: "or_predecessor.testnet".to_string(),
            input,
            block_index: 0,
            block_timestamp: 0,
            account_balance: 0,
            account_locked_balance: 0,
            storage_usage: 0,
            attached_deposit: 0,
            prepaid_gas: 10u64.pow(18),
            random_seed: vec![0, 1, 2],
            is_view,
            output_data_receivers: vec![],
            epoch_height: 19,
        }
    }
	
	fn get_default_or()-> OpenRoles {
		let context = get_context(vec![], false);
		let mut or = OpenRoles {
						role_administrator : context.predecessor_account_id,
						contract_by_contract_account_id : HashMap::new(),
						lists : HashMap::new(),
						list_names : Vec::new(),
					};
		or
	}
	
	#[test]
	fn test_set_role_administrator() {
		let context = get_context(vec![], false);
		testing_env!(context);
		
		let mut contract = get_default_or();
		let new_admin = "test_admin.testnet".to_string();
		contract.set_role_administrator(new_admin.clone());
		assert_eq!(new_admin, contract.view_role_administrator());
	}
	
}