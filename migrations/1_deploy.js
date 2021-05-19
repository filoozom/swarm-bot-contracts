/* global artifacts */
require("dotenv").config();

// Imports
const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

// Artifacts
const SwarmFaucet = artifacts.require("SwarmFaucet");

module.exports = async (deployer) => {
  // Deploy as upgradeable contract
  /*
  const upgrade = false;

  if (upgrade) {
    await upgradeProxy(
      "0xB3fDdA6Ba8C77aAEAEd58FFb1f652b7c264AEd7C",
      SwarmFaucet,
      { deployer }
    );
  } else {
    await deployProxy(
      SwarmFaucet,
      [
        "0x2ac3c1d3e24b45c6c310534bc2dd84b5ed576335",
        "50000000000000000",
        "100000000000000000",
      ],
      { deployer, initializer: "initialize" }
    );
  }
  */

  // Deploy
  await deployer.deploy(SwarmFaucet);
  const instance = await SwarmFaucet.deployed();

  // Initialize
  await instance.initialize(
    "0x2ac3c1d3e24b45c6c310534bc2dd84b5ed576335",
    "50000000000000000",
    "10000000000000000"
  );

  // Add admin
  await instance.grantRole(
    await instance.ADMIN_ROLE(),
    "0xD796eB206d58f39Aaf58b401cE47CCDE1cac5597"
  );

  // Add funder
  await instance.grantRole(
    await instance.FUNDER_ROLE(),
    "0x38707cdD094Cf507f347f61B960FBbf545185A71"
  );
};
