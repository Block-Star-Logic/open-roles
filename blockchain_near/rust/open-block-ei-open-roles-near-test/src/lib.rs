#![allow(dead_code)]
use num::{self, ToPrimitive};
use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen, json_types, ext_contract, Promise,PromiseOrValue,};

near_sdk::setup_alloc!();

#[ext_contract(ext_open_roles_admin)]
pub trait TOpenRolesAdmin { 

    // Returns the version number of the implementation
    fn get_version(&self) -> PromiseOrValue<Vec<String>>;

    /// Provides a list of list_names currently held by this instance. This will include names of **DELETED** lists 
    fn view_list_names(&self) -> PromiseOrValue<Vec<String>>;
    
    /// Provides a view of the list consisting of the name, type, NEAR account ids held and status of the list 
    fn view_list(&self, list_name: String) -> PromiseOrValue<Vec<String>>;

    /// Provides a view of the currently assigned role administrator for this instance 
    fn view_role_administrator(&self) -> PromiseOrValue<String>;
    
    /// Checks whether the given **DependentContract** is registered under the given **concract_account_id** 
    fn is_registered(&self, contract_account_id : String, contract_name : String) -> PromiseOrValue<bool>;
    
    /// Assigns the given **list** to the given operation on the given contract deployed at the given NEAR account id
    fn assign_list_to_operation( &self, contract_account_id: String, contract_name: String, operation: String, list_name: String ) -> PromiseOrValue<String>;

    /// Removes the given **list** from the given operation on the given contract deployed on the given NEAR account id         
    fn remove_list_from_operation( &self, contract_account_id: String, contract_name: String, operation: String ) -> PromiseOrValue<String>;

    /// Creates the given **list** with **ACTIVE** status         
    fn create_list( &self, list_name: String, list_type: String) -> PromiseOrValue<String>;

    /// Deletes the given **list** from those available by setting the list status to **DELETED**        
    fn delete_list(&self, list_name: String)  -> PromiseOrValue<String>;
    
    /// Adds a NEAR blockchain user_account_id to the given **list_name** from those available 
    fn add_account_id_to_list( &self, user_account_id: String, list_name: String ) -> PromiseOrValue<String>;

    /// Removes the given NEAR blockchain user_account_id from the given **list** 
    fn remove_account_from_list( &self, user_account_id: String, list_name: String ) -> PromiseOrValue<String>;

    /// Registers the given contract as deployed on the given **contract_account_id** with the given operations 
    fn register_contract( &self, contract_account_id: String, contract_name: String, ops: Vec<String> )  -> PromiseOrValue<String>;

    /// Deregisters the given NEAR **contract** deployed at the given NEAR blockchain **contract_account_id**
    fn deregister_contract( &self, contract_account_id: String, contract_name: String )  -> PromiseOrValue<String>;

    /// Provides a view of the currently assigned role administrator for this instance 
    fn set_role_administrator(&self, account_id: String)-> PromiseOrValue<bool>;

}
#[ext_contract(ext_open_roles)]
pub trait TOpenRoles {

    /// Checks whether the given on chain **'user_account_id'**  is allowed to access the stated operation (function)
    fn is_allowed(&self, contract_account_id : String, contract_name : String, operation : String, user_account_id : String) -> PromiseOrValue<i32>;
    
    /// Checks whether the given on chain **'user_account_id'**  is barred from access the stated operation (function)
    fn is_barred(&self, contract_account_id : String, contract_name :String, operation : String, user_account_id : String) -> PromiseOrValue<i32>; 
}
const OPEN_ROLES_DEPLOYMENT_ACCOUNT_ID: &str = "blockstarlogic1.testnet";
const NO_DEPOSIT: near_sdk::Balance = 0;
const BASE_GAS: near_sdk::Gas = 5_000_000_000_000;

#[near_bindgen]
#[derive(Default, BorshDeserialize, BorshSerialize)]
struct SmokeTestApp {	
	
    open_roles_deployment_account_id : String, 
    deposit : near_sdk::Balance,
    
}

#[near_bindgen]
impl SmokeTestApp {


    pub fn is_allowed(&self, contract_account_id : String, contract_name : String, operation : String, user_account_id : String) -> PromiseOrValue<i32>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();
        ext_open_roles::is_allowed(contract_account_id, contract_name, operation, user_account_id, &or_account_id, self.deposit, BASE_GAS).into()
    }

    pub fn is_barred(&self, contract_account_id : String, contract_name :String, operation : String, user_account_id : String) -> PromiseOrValue<i32> {
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();
        ext_open_roles::is_barred(contract_account_id, contract_name, operation, user_account_id, &or_account_id, self.deposit, BASE_GAS).into()
    }

    pub fn get_version(&self) -> PromiseOrValue<Vec<String>>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();		
        ext_open_roles_admin::get_version(&or_account_id, self.deposit, BASE_GAS).into()
    }
    pub fn view_list_names(&self) -> PromiseOrValue<Vec<String>> {
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::view_list_names(&or_account_id, self.deposit, BASE_GAS).into()
    } 
            
    pub fn view_list(&self, list_name: String) -> PromiseOrValue<Vec<String>>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::view_list(list_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    pub fn view_role_administrator(&self) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::view_role_administrator(&or_account_id, self.deposit, BASE_GAS).into()
    }
        
    pub fn is_registered(&self, contract_account_id : String, contract_name : String) -> PromiseOrValue<bool>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::is_registered(contract_account_id, contract_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
        
    
    pub fn assign_list_to_operation( &self, contract_account_id: String, contract_name: String, operation: String, list_name: String ) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::assign_list_to_operation(contract_account_id, contract_name, operation, list_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
        
    pub fn remove_list_from_operation( &self, contract_account_id: String, contract_name: String, operation: String ) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::remove_list_from_operation(contract_account_id, contract_name, operation, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn create_list( &self, list_name: String, list_type: String) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::create_list(list_name, list_type, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn delete_list(&self, list_name: String)  -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::delete_list(list_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
        
    
    pub fn add_account_id_to_list( &self, user_account_id: String, list_name: String ) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::add_account_id_to_list(user_account_id, list_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn remove_account_from_list( &self, user_account_id: String, list_name: String ) -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::remove_account_from_list(user_account_id,list_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn register_contract( &self, contract_account_id: String, contract_name: String, ops: Vec<String> )  -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::register_contract(contract_account_id, contract_name, ops, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn deregister_contract( &self, contract_account_id: String, contract_name: String )  -> PromiseOrValue<String>{
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::deregister_contract(contract_account_id, contract_name, &or_account_id, self.deposit, BASE_GAS).into()
    }
    
    
    pub fn set_role_administrator(&self, account_id: String)-> PromiseOrValue<bool> {
        let or_account_id: near_sdk::AccountId = self.open_roles_deployment_account_id.to_string();			
        ext_open_roles_admin::set_role_administrator(account_id, &or_account_id, self.deposit, BASE_GAS).into()
    }

    pub fn set_or_deployment_account_id(& mut self, account_id: String) -> bool {
        self.open_roles_deployment_account_id = account_id; 
        true
    }

    pub fn step0_setup_lists(&mut self) ->bool {
        self.create_list("test_allow_list".to_string(), "ALLOW".to_string());
        self.create_list("test_barred_list".to_string(), "BARRED".to_string());
        true
    }

    pub fn step1_register_contract1(&mut self) -> bool {
        let mut ops = Vec::<String>::new();
        ops.push("test_op_red".to_string());
        ops.push("test_op_green".to_string());
        ops.push("test_op_blue".to_string());
        self.register_contract("test_deploy_account".to_string(), "test_contract".to_string() , ops);
        
        true
    }

    pub fn step2_register_contract2(&mut self) ->bool {
        let mut ops2 = Vec::<String>::new();
        ops2.push("test_op_yellow".to_string());
        ops2.push("test_op_orange".to_string());
        ops2.push("test_op_purple".to_string());
        self.register_contract("test_deploy_account".to_string(), "test_contract_next".to_string() , ops2);

        true
    }


    pub fn step3_assign_lists_to_ops(&mut self) -> bool {
        self.assign_list_to_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_allow_list".to_string());
     
        self.assign_list_to_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_barred_list".to_string());
 
        true
    }

    pub fn step4_add_users(&mut self)  -> bool {
        self.add_account_id_to_list("test_user_account_alpha.testnet".to_string(), "test_allow_list".to_string());
    
        self.add_account_id_to_list("test_user_account_beta.testnet".to_string(), "test_allow_list".to_string());
    
        self.add_account_id_to_list("test_user_account_gamma.testnet".to_string(), "test_barred_list".to_string());
    
        self.add_account_id_to_list("test_user_account_octo.testnet".to_string(), "test_barred_list".to_string());

        true
    }

    pub fn test_is_allowed(&mut self) -> Vec<String>{ 

        let mut results = Vec::<String>::new();


        self.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_user_account_beta.testnet".to_string());
        let mut test_result_0 : i32  = -5;
        match env::promise_result(0) {
           near_sdk::PromiseResult::Successful(x) => test_result_0 = num::ToPrimitive::to_i32(x.get(0).unwrap()).unwrap(),
            _ => results.push("Promise failure test_result_0".to_string()),
        };
        
        assert_eq!(1, test_result_0.clone());

        results.push(format!("test result 0 value : {}, ok", test_result_0));

        self.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_user_account_gamma.testnet".to_string());

        let mut test_result_1 : i32  = -5;
        match env::promise_result(0) {
            near_sdk::PromiseResult::Successful(x) => test_result_1 = num::ToPrimitive::to_i32(x.get(0).unwrap()).unwrap(),
             _ => results.push("Promise failure test_result_1".to_string()),
         };       
        
        assert_eq!(0, test_result_1.clone());

        results.push(format!("test result 1 value : {}, ok", test_result_1));
       
        results

    }

    pub fn  test_is_barred(&mut self) -> Vec<String> { 
        
        let mut results = Vec::<String>::new();

        self.is_barred("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_user_account_gamma.testnet".to_string());
        let mut test_result_2 : i32 = -5;
        match env::promise_result(0) {
            near_sdk::PromiseResult::Successful(x) => test_result_2 = num::ToPrimitive::to_i32(x.get(0).unwrap()).unwrap(),
             _ => results.push("Promise failure test_result_2".to_string()),
        };   
         assert_eq!(1, test_result_2.clone() );
        
        results.push(format!("test result 2 value : {}, ok", test_result_2));

        self.is_barred("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_user_account_beta.testnet".to_string());
        let mut test_result_3 : i32 = -5;
        match env::promise_result(0) {
            near_sdk::PromiseResult::Successful(x) => test_result_3 = num::ToPrimitive::to_i32(x.get(0).unwrap()).unwrap(),
             _ => results.push("Promise failure test_result_3".to_string()),
         };         
        assert_eq!(0, test_result_3.clone());

        results.push(format!("test result 3 value : {}, ok", test_result_3));

        results

    }

    /// tear down a limited number of smoke test items 
    pub fn tear_down(&mut self) -> bool {
        
        self.remove_account_from_list("test_allow_list".to_string(), "test_user_account_beta.testnet".to_string());

        self.remove_list_from_operation( "test_deploy_account".to_string(), "test_op_green".to_string(), "test_allow_list".to_string(),);

        self.deregister_contract("test_deploy_account".to_string(), "test_contract".to_string());

        true
    }

    // totally clear out all smoke test items the remote or contract 
    pub fn clean_out(&mut self) -> bool {

        self.delete_list("test_allow_list".to_string());
        
        self.delete_list("test_barred_list".to_string());
        
        true
    }

}