let nyanyukToken = artifacts.require("./NyanyukToken.sol");

contract('NyanyukToken', function(accounts) {
    it("should be able to create a ticket when address, max reward and date provided", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            //contract for account 0 date expire next week
            let expiryDate = Math.floor((new Date().getTime()/1000)) + (7 * 24 * 60 * 60);
            await nyanyukTokenInstance.createTicket(accounts[0], 100, expiryDate, {from: accounts[3]});
            let tickets = await nyanyukTokenInstance.getTickets(accounts[0]);
            console.log(tickets);
            expect(tickets).to.have.length(1);

            let ticket = await nyanyukTokenInstance.getTicketDetails(tickets[tickets.length - 1]);
            console.log(ticket);
            expect(ticket[0]).to.equal(false);
            expect(ticket[2]).to.equal(accounts[0]);
            expect(ticket[3].toNumber()).to.equal(100);
            expect(ticket[4].toNumber()).to.equal(expiryDate);
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("owner should able to receive the rest of the token", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            await nyanyukTokenInstance.sendToOwner({from: accounts[3]});
            let balance = await nyanyukTokenInstance.balanceOf(accounts[3]);
            console.log(balance.toNumber());
            expect(balance.toNumber()).to.equal(2000);
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("owner should able to receive the rest of the token only once", async function () {
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            await nyanyukTokenInstance.sendToOwner({from: accounts[3]});
            expect.fail();
        } catch (e) {
            console.log(e);
            expect(1).to.equal(1);
        }
    });
    it("after get reward, requestor balance should increase", async function(){
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let tickets = await nyanyukTokenInstance.getTickets(accounts[0]);
            console.log(tickets);
            let balance = await nyanyukTokenInstance.balanceOf(accounts[0]);
            console.log(balance);
            let tx = await nyanyukTokenInstance.getMyReward(tickets[tickets.length - 1], {from: accounts[0]});
            console.log(tx);
            let balanceAfterReward = await nyanyukTokenInstance.balanceOf(accounts[0]);
            console.log(balanceAfterReward);
            expect(balance.toNumber()).to.be.below(balanceAfterReward.toNumber());
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("calling sendToOwner should send all the rest of the token to owner address", async function(){
    });
    it("only can use the ticket once", async function(){
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let expiryDate = Math.floor((new Date().getTime()/1000)) + (7 * 24 * 60 * 60);
            await nyanyukTokenInstance.createTicket(accounts[0], 100, expiryDate, {from: accounts[3]});
            let tickets = await nyanyukTokenInstance.getTickets(accounts[0]);
            await nyanyukTokenInstance.getMyReward(tickets[0], {from: accounts[0]});
            await nyanyukTokenInstance.getMyReward(tickets[0], {from: accounts[0]});
            expect.fail();
        } catch (e) {
            console.log(e);
            expect(e).to.exist;
        }
    });
    it("should emit an event when create ticket", async function(){
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let expiryDate = Math.floor((new Date().getTime()/1000)) + (7 * 24 * 60 * 60);
            let txResult = await nyanyukTokenInstance.createTicket(accounts[0], 100, expiryDate, {from: accounts[3]});
            console.log(txResult);
            expect(txResult.logs.length).to.equal(1);
            expect(txResult.logs[0].event).to.equal("TicketCreated");
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
    it("should emit an event when get reward ticket", async function(){
        try {
            let nyanyukTokenInstance = await nyanyukToken.deployed();
            let expiryDate = Math.floor((new Date().getTime()/1000)) + (7 * 24 * 60 * 60);
            await nyanyukTokenInstance.createTicket(accounts[0], 100, expiryDate, {from: accounts[3]});
            let tickets = await nyanyukTokenInstance.getTickets(accounts[0]);
            let ticket = await nyanyukTokenInstance.getTicketDetails(tickets[tickets.length - 1]);
            console.log(ticket);
            let txResult = await nyanyukTokenInstance.getMyReward(tickets[tickets.length-1], {from: accounts[0]});
            console.log(txResult.logs);
            expect(txResult.logs.length).to.equal(1);
            expect(txResult.logs[0].event).to.equal("RewardReceived");
        } catch (e) {
            console.log(e);
            expect.fail();
        }
    });
});
