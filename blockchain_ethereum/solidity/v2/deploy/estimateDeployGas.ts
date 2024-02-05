import { estimateGas } from "./utils";
import { formatEther } from "ethers/lib/utils";

export default async function () {
    const contractArtifactName = "OpenRolesAdmin";
    const constructorArguments = ["<YOUR ADMIN ADDRESS>"];
    const deployGasOra = await estimateGas(contractArtifactName, constructorArguments);
  
    const openRolesArtifact = "OpenRoles"; 
    const orConstructorArguments = ["0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"];
    const deployGasOr = await estimateGas(openRolesArtifact, orConstructorArguments);

    console.log(`Total Gas required: ${formatEther(deployGasOra.add(deployGasOr))} ETH`); 
  }