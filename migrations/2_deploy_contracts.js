var ChangeManager = artifacts.require("./ChangeManager.sol");

module.exports = function(deployer) {
  deployer.deploy(ChangeManager);
};
