var NyanyukTokenMigration = artifacts.require("./NyanyukToken.sol");
var GamblingPlatformMigration = artifacts.require("./GamblingPlatform.sol");

module.exports = function(deployer, network, accounts) {
  if (network === "test") {
      // NyanyukTokenMigration.deployed().then(s => {
      //     console.log(s.address);
      //     deployer.deploy(GamblingPlatformMigration, 100, accounts[3], {from: accounts[3]}).then(abc => {
      //         console.log("try here");
      //         GamblingPlatformMigration.deployed().then(def => {
      //             console.log(def);
      //         })
      //     });
      // });
      deployer.deploy(GamblingPlatformMigration, 100, accounts[3], {from: accounts[3]}).then(abc => {
          console.log("try here");
          GamblingPlatformMigration.deployed().then(def => {
              console.log(def);
          })
      });
      //     deployer.deploy(GamblingPlatformMigration, 100, {from: accounts[3]}).then(abc => {
      //         console.log("try here");
      //         GamblingPlatformMigration.deployed().then(def => {
      //             console.log(def.address);
      //         })
      //     });

  } else {
      NyanyukTokenMigration.deployed().then(s => {
          console.log(s.address);
          deployer.deploy(GamblingPlatformMigration, 100, s.address, {from: accounts[0]}).then(s => {
              console.log(s);
          });
      });
  }
};
