//! SPDX-License-Identifier: APACHE 2.0 
//!
//! # OpenRoles::or_traits 
//!
//! <br/> @author : Block Star Logic 
//! <br/> @coder : T Ushewokunze 
//! <br/> @license :  Apache 2.0 
//!
//! These trait are implmented by the calling contracts 
//! - [TOpenRoles] is implemented for front facing contracts e.g. dApps 
//! - [TOpenRolesAdmin] is implemented by back-end admin dApps and dashboards
//! These traits are **'not'** payable 
//!
use near_sdk::borsh::{BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen, json_types, ext_contract, PromiseResult, Promise, PromiseOrValue,};

#[ext_contract(ext_open_roles)]
pub trait TOpenRoles {

    /// Checks whether the given on chain **'user_account_id'**  is allowed to access the stated operation (function)
    fn is_allowed(&self, contract_account_id : String, contract_name : String, operation : String, user_account_id : String) -> PromiseOrValue<bool>;
    
    /// Checks whether the given on chain **'user_account_id'**  is barred from access the stated operation (function)
    fn is_barred(&self, contract_account_id : String, contract_name :String, operation : String, user_account_id : String) -> PromiseOrValue<bool>; 
}

#[ext_contract(ext_open_roles_admin)]
pub trait TOpenRolesAdmin { 

    // Returns the version number of the implementation
    fn get_version(&self) -> PromiseOrValue<Vec<String>>;

    // Returns the id of the deployed instance
    fn get_id(&self) -> PromiseOrValue<Vec<String>>;

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
