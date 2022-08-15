import { ethers } from "hardhat";

async function main() {
  const Trafik = await ethers.getContractFactory("Trafik");
  const TrafikContract = await Trafik.deploy();

  await TrafikContract.deployed();

  console.log("Trafik deployed to:", TrafikContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
