var Monopoly = artifacts.require("./Monopoly.sol");

module.exports = function(deployer) {
  deployer.deploy(Monopoly);
};
