var NyanyukTokenMigration = artifacts.require("./NyanyukToken.sol");
var GamblingPlatformMigration = artifacts.require("./GamblingPlatform.sol");

module.exports = function(deployer, network, accounts) {
  if (network === "test") {
      deployer.deploy(NyanyukTokenMigration, 200, 40, 2, {from: accounts[3]}).then(() => {
          return deployer.deploy(GamblingPlatformMigration, 50, NyanyukTokenMigration.address, {from: accounts[3]});
      });
  } else {
      deployer.deploy(NyanyukTokenMigration, 1000000, 200, 10, {from: accounts[0]}).then(() => {
          return deployer.deploy(GamblingPlatformMigration, 100, NyanyukTokenMigration.address, {from: accounts[0]});
      });
  }
};
