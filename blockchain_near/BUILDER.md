# Open Roles on NEAR - Builders Guide

This guide has been prepared for Builders on the NEAR blockchain. 

This implementation of Open Roles is built on using the RUST programming language. 
It utlises the NEAR RUST SDK for more information see <a href="https://docs.near.org/docs/develop/contracts/rust/intro">here</a>
For information on RUST see <a href="https://www.rust-lang.org/">here.</a>

## Design 

Open Roles has been built using a "plugin" design pattern that allow for easy replacement and extension. The model is described in the diagram below :
<img src="https://github.com/Block-Star-Logic/open-roles/blob/3c2da814ed7c726395b0df2971f23ecd8241f0df/blockchain_near/media/open_roles_design.png"/>

In the diagram the user is only allowed access to the dApp functions for which they hav been given access by Open Roles. To configure this access the administrator has to implement a role matrix as described in the <a href="ADMIN.md">Administrators Guide</a>.

This implementation utilises cross contract calls between the dApp and the Open Roles deployment. 

## How to implement

The RUST API documentation for this implementation can be found on <font color="red">Docs.rs <a href="https://docs.rs/">here</a></font>
<br/>The RUST distribution can be downloaded from <font color="red">Crates.io <a href="">here</a></font>

### User Facing
To access your Open Roles deployment from your dApp in a user facing capacity you need to do the following 

1. Implement the ```open-block-ei-open-roles-near-core::or_traits::TOpenRoles``` trait in your dApp 
2. Deploy your Open Roles instance - to deploy Open Roles follow the instructions in the <a href="ADMIN.md">Administrators Guide</a>. 
3. Configure your Role Matrix (NOTE: each operation in your dApp can only be assigned one participant list).

### Administrator Facing
To access your Open Roles deployment from your dApp in an administrator facing capacity e.g. for bulk work utilities, you need to do the following:
1. Implement the ```open-block-ei-open-roles-near-core::or_traits::TOpenRolesAdmin``` trait in your dApp
2. Deploy your Open Roles instance - to deploy Open Roles follow the instructions in the <a href="ADMIN.md">Administrators Guide</a>. 
3. Configure your Role Matrix 


**for further support join our <a href="https://rebrand.ly/obei_or_git">Discord</a> on the #dev-support channel**
