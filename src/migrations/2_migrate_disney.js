const disney = artifacts.require("Disney");

module.exports = function(deployer) {
  deployer.deploy(disney);
};
