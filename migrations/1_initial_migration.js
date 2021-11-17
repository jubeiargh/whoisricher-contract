const WhoIsRicher = artifacts.require("WhoIsRicherContract");

module.exports = function (deployer) {
  deployer.deploy(WhoIsRicher);
};
