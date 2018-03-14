var nyanyukToken = artifacts.require("./NyanyukToken.sol");

contract('NyanyukToken', function(accounts) {
    it("should be able to get token randomly between max reward number", async function() {
        let myTokenInstance = await nyanyukToken.deployed();
        let promiseArr = [];
        for (let i = 0; i<5; i++) {
            promiseArr.push (myTokenInstance.getMyReward (5, { from: accounts[i]}));
        }

        let maxReward = await myTokenInstance.getMaxReward.call();

        Promise.all(promiseArr).then((res) => {
           if (res.filter(s => s === 0).length > 0) {
               expect.fail();
           } else {
               expect(res.filter(s => s < maxReward)).to.have.length(5);
           }
        }, () => {
            expect.fail();
        });
    });
    it("deterministic should not affect anything on random creation if deterministic increase, value should not keep increase", async function() {
        let myTokenInstance = await nyanyukToken.deployed();
        let promiseArr = [];
        for (let i = 0; i < 10; i++) {
            promiseArr.push (myTokenInstance.getMyReward(i + 40, { from: accounts[i]}));
        }
        let totalSupply = await myTokenInstance.getMaxReward.call();
        Promise.all(promiseArr).then((res) => {
            let lastexp = res[0];
            let increaseNum = 0;
            for (let exp = 1; exp < 10; exp++) {
                if (lastexp < res[exp]) {
                    increaseNum++;
                }
                lastexp = res[exp];
            }
            expect(increaseNum).to.be.at.most(8);
        }, () => {
            expect.fail();
        });
    });
    it("should receive the reward to their account", function() {
    });
    it("one address should only able to get rewards one time", function() {
    });
    it("should should only dispense as much as the max reward", function() {
    });
    it("should throw an error if max reward has been finished", function() {
    });
    it("if a user get reward more than total reward available give all of the reward", function() {
    });
});
