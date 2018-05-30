let nyanyukToken = artifacts.require("./NyanyukToken.sol");
let gamblingPlatform = artifacts.require("./GamblingPlatform.sol");


contract('GamblingPlatform', function(accounts) {
    it("owner should able to deposit token inside", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();

            let gamblingPlatformInstance = await gamblingPlatform.deployed();

            await nyanyukTokenInstance.sendToOwner({from: accounts[3]});

            let supplyBefore = await gamblingPlatformInstance.getBankBalance();
            expect(supplyBefore.toNumber()).to.equal(0);

            await nyanyukTokenInstance.approve(gamblingPlatformInstance.address, 100, {from: accounts[3]});

            await gamblingPlatformInstance.ownerDeposit(100, {from: accounts[3]});
            let ownerBalance = await nyanyukTokenInstance.balanceOf(accounts[3]);

            expect(ownerBalance.toNumber()).to.equal(100);

            let supplyAfter = await gamblingPlatformInstance.getBankBalance();
            expect(supplyAfter.toNumber()).to.equal(100);
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("owner should able to withdraw token inside", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let gamblingPlatformInstance = await gamblingPlatform.deployed();
            await gamblingPlatformInstance.ownerWithdraw(50, {from: accounts[3]});

            let supplyAfter = await gamblingPlatformInstance.getBankBalance();
            let ownerBalance = await nyanyukTokenInstance.balanceOf(accounts[3]);

            expect(supplyAfter.toNumber()).to.equal(50);
            expect(ownerBalance.toNumber()).to.equal(150);
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("player should able to deposit token inside", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let gamblingPlatformInstance = await gamblingPlatform.deployed();

            await nyanyukTokenInstance.transfer(accounts[1], 100, {from: accounts[3]});
            await nyanyukTokenInstance.approve(gamblingPlatformInstance.address, 100, {from: accounts[1]});

            await gamblingPlatformInstance.playerDeposit(100, {from: accounts[1]});

            let playerBalance = await gamblingPlatformInstance.getPlayerBalance(accounts[1], {from: accounts[1]});
            expect(playerBalance.toNumber()).to.equal(100);
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    // it("player should able to withdraw token inside", async function () {
    //     try {
    //         let nyanyukTokenInstance = await nyanyukToken.deployed();
    //         let gamblingPlatformInstance = await gamblingPlatform.deployed();
    //         await nyanyukTokenInstance.transfer(accounts[1], 100, {from: accounts[3]});
    //         await nyanyukTokenInstance.playerWithdraw(30, {from: accounts[1]});
    //         let playerBalance = await gamblingPlatformInstance.getPlayerBalance({from: accounts[1]});
    //         expect(playerBalance).to.equal(30);
    //     } catch (e) {
    //         console.log(e);
    //         expect.fail();
    //     }
    // });
    // it("should throw error if user bet more than the total supply", async function () {
    //     try {
    //         let gamblingPlatformInstance = await gamblingPlatform.deployed();
    //         await gamblingPlatformInstance.bet(40, {from: accounts[1]});
    //         expect.fail();
    //     } catch (e) {
    //         console.log(e);
    //         expect(e).to.exist;
    //     }
    // });
    // it("should be able to bet", async function () {
    //     try {
    //         let gamblingPlatformInstance = await gamblingPlatform.deployed();
    //         let txResult = await gamblingPlatformInstance.bet(20, {from: accounts[1]});
    //         console.log(txResult);
    //         expect(txResult.logs.length).to.equal(1);
    //         expect(txResult.logs[0].event).to.equal("BetCreated");
    //     } catch (e) {
    //         console.log(e);
    //         expect.fail();
    //     }
    // });
});
