import { deployContract, verifyEnoughBalance, getWallet } from "./utils";
import { estimateGas } from "./utils";
import { formatEther } from "ethers/lib/utils";
import { Wallet } from "zksync-web3";
// An example of a basic deploy script
// It will deploy a Greeter contract to selected network
// as well as verify it on Block Explorer if possible for the network
export default async function () {

  const wallet = getWallet();
  const openRolesAdminArtifactName = "OpenRolesAdmin";
  const openRolesAdminConstructorArguments = ["<YOUR ADMIN/OWNER ADDRESS>"];

  const openRolesArtifact = "OpenRoles"; 
  var orConstructorArguments = ["0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"]; // will be automatically replaced during deployment
  
  const deployOraGasEstimate = await estimateGas(openRolesAdminArtifactName, openRolesAdminConstructorArguments);
  const deployOrGasEstimate = await estimateGas(openRolesArtifact, orConstructorArguments);

  const totalGas = deployOraGasEstimate.add(deployOrGasEstimate);

  console.log(`Total Gas required: ${formatEther(totalGas)} ETH`); 
  try {
    const sufficient = await verifyEnoughBalance(wallet, totalGas);

    const openRolesAdminContract = await deployContract(openRolesAdminArtifactName, openRolesAdminConstructorArguments); 
    console.log("Open Roles Admin Address: " + openRolesAdminContract.address);
    orConstructorArguments = [openRolesAdminContract.address];
    const openRolesContract = await deployContract(openRolesArtifact, orConstructorArguments);
    console.log("Open Roles Admin Address: " + openRolesContract.address);
  } 
  catch(error) {
    console.log(error);
  }
}



