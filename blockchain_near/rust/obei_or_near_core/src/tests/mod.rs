
use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::{env, near_bindgen,};
use near_sdk::collections::{UnorderedSet, LookupMap, Vector,};
use core::panic;
use std::collections::{HashMap, HashSet,};
use std::convert::TryFrom;

#[cfg(test)]

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

fn get_default_or()-> super::OpenRoles {
    let context = get_context(vec![], false);
    let mut or = super::OpenRoles::new();

    or.create_list("test_allow_list".to_string(), "ALLOW".to_string());
    or.create_list("test_barred_list".to_string(), "BARRED".to_string());
    let mut ops = Vec::<String>::new();
    ops.push("test_op_red".to_string());
    ops.push("test_op_green".to_string());
    ops.push("test_op_blue".to_string());
    or.register_contract("test_deploy_account".to_string(), "test_contract".to_string() , ops);

    let mut ops2 = Vec::<String>::new();
    ops2.push("test_op_yellow".to_string());
    ops2.push("test_op_orange".to_string());
    ops2.push("test_op_purple".to_string());
    or.register_contract("test_deploy_account".to_string(), "test_contract_next".to_string() , ops2);

    or.assign_list_to_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_allow_list".to_string());
 
    or.assign_list_to_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_barred_list".to_string());
   
    or.add_account_id_to_list("test_user_account_alpha.testnet".to_string(), "test_allow_list".to_string());

    or.add_account_id_to_list("test_user_account_beta.testnet".to_string(), "test_allow_list".to_string());

    or.add_account_id_to_list("test_user_account_gamma.testnet".to_string(), "test_barred_list".to_string());

    or.add_account_id_to_list("test_user_account_octo.testnet".to_string(), "test_barred_list".to_string());

    or
}

#[test]//@ done
fn test_is_allowed() { 
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let or_governor = get_default_or();
    assert_eq!(true, or_governor.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_user_account_beta.testnet".to_string()));

    assert_eq!(false, or_governor.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_user_account_gamma.testnet".to_string()))

}

#[test]//@ done
fn test_is_barred(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    assert_eq!(true, or_governor.is_barred("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_user_account_gamma.testnet".to_string()));

    assert_eq!(false, or_governor.is_barred("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_user_account_beta.testnet".to_string()))

}

#[test]//@ done
fn test_view_list_names(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();

    let list_names = or_governor.view_list_names();
   
    assert!(list_names.contains(&"test_allow_list".to_string()));
    assert!(list_names.contains(&"test_barred_list".to_string()))
}

#[test]//@ done
fn test_view_list() { 
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let or_governor = get_default_or();

    let (name, list_type, ids, status) = or_governor.view_list("test_allow_list".to_string());
    assert_eq!("ALLOW", list_type);
    assert!(ids.contains(&"test_user_account_alpha.testnet".to_string()));
    assert!(ids.contains(&"test_user_account_beta.testnet".to_string()));
    assert_eq!("ACTIVE", status);
}

#[test]//@ done
fn test_view_role_administrator(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let or_governor = get_default_or();
    let env_admin = env::current_account_id();
    assert_eq!(env_admin.to_string(), or_governor.view_role_administrator().to_string())
}

#[test]//@ done
fn test_is_registered(){ 
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let or_governor = get_default_or();
    assert!(or_governor.is_registered("test_deploy_account".to_string(), "test_contract".to_string()));
    assert!(!or_governor.is_registered("test_deploy_account".to_string(), "test_null_contract".to_string()));
}

#[test]//@ done
fn test_assign_list_to_operation(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    or_governor.create_list("test_allow_next".to_string(), "ALLOW".to_string());
    or_governor.add_account_id_to_list("bob.testnet".to_string(), "test_allow_next".to_string());
    
    or_governor.assign_list_to_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_blue".to_string(), "test_allow_next".to_string());
    
    assert!(or_governor.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_blue".to_string(), "bob.testnet".to_string()))
}

#[test]//@ done
fn test_remove_list_from_operation() {
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
   
    or_governor.remove_list_from_operation("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string());

    let assignments = or_governor.view_list_assignments("test_allow_list".to_string());
    
    for assignment  in assignments { 
        if assignment.operation.as_bytes() ==  "test_op_green".as_bytes() {
            assert!(false);
        }
    }    
}

#[test]//@ done
fn test_view_list_assignments() {
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    let assignments = or_governor.view_list_assignments("test_allow_list".to_string());    
    assert_eq!(1, assignments.len());
}

#[test] //@ done
fn test_create_list(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    or_governor.create_list("test_allow_list_new".to_string(), "ALLOW".to_string());

    let list_names = or_governor.view_list_names();

    assert!(list_names.contains(&"test_allow_list_new".to_string()));
}

#[test] //@ done
fn test_delete_list(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    or_governor.delete_list("test_allow_list".to_string()); 

    assert!(!or_governor.view_list_names().contains(&"test_allow_list".to_string()));

}


#[test] //@ done
fn test_add_account_id_to_list(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();

    or_governor.add_account_id_to_list("test_user_account_theta.testnet".to_string(), "test_barred_list".to_string());

    assert_eq!(true, or_governor.is_barred("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_red".to_string(), "test_user_account_theta.testnet".to_string()));
}

#[test] //@ done
fn test_remove_account_from_list(){ 
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();

    or_governor.remove_account_from_list("test_user_account_alpha.testnet".to_string(),"test_allow_list".to_string());

    assert_eq!(false, or_governor.is_allowed("test_deploy_account".to_string(), "test_contract".to_string(), "test_op_green".to_string(), "test_user_account_alpha.testnet".to_string()));

}

#[test] //@ done
fn test_register_contract() { 
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();
    let mut ops = Vec::<String>::new();
    ops.push("test_op_lilo".to_string());
    ops.push("test_op_sitch".to_string());
    ops.push("test_op_tamarin".to_string());
    or_governor.register_contract("test_deploy_account_phiph".to_string(), "test_contract_zeta".to_string() , ops);

    assert!(or_governor.is_registered("test_deploy_account_phiph".to_string(), "test_contract_zeta".to_string()));
}

#[test]//@ done
fn test_deregister_contract(){
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let mut or_governor = get_default_or();

    or_governor.deregister_contract("test_deploy_account".to_string(), "test_contract".to_string());

    assert!(!or_governor.is_registered("test_deploy_account".to_string(), "test_contract".to_string()));
}

#[test] //@ done
fn test_set_role_administrator() {
    let context = get_context(vec![], false);
    testing_env!(context);
    
    let new_admin = "test_admin.testnet".to_string();
    let mut or_governor = get_default_or();
    
	or_governor.set_role_administrator(new_admin.clone());
	assert_eq!(new_admin, or_governor.view_role_administrator());
}




