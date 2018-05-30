let ChangeManager = artifacts.require("./ChangeManager.sol");
let ChangeRequest = artifacts.require("./ChangeRequest.sol");

// contract('MetaCoin', function(accounts) {
//   it("should put 10000 MetaCoin in the first account", function() {
//     return MetaCoin.deployed().then(function(instance) {
//       return instance.getBalance.call(accounts[0]);
//     }).then(function(balance) {
//       assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
//     });
//   });
//   it("should call a function that depends on a linked library", function() {
//     var meta;
//     var metaCoinBalance;
//     var metaCoinEthBalance;
//
//     return MetaCoin.deployed().then(function(instance) {
//       meta = instance;
//       return meta.getBalance.call(accounts[0]);
//     }).then(function(outCoinBalance) {
//       metaCoinBalance = outCoinBalance.toNumber();
//       return meta.getBalanceInEth.call(accounts[0]);
//     }).then(function(outCoinBalanceEth) {
//       metaCoinEthBalance = outCoinBalanceEth.toNumber();
//     }).then(function() {
//       assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpeced function, linkage may be broken");
//     });
//   });
//
//   it("should send coin correctly", function() {
//     var meta;
//
//     //    Get initial balances of first and second account.
//     var account_one = accounts[0];
//     var account_two = accounts[1];
//
//     var account_one_starting_balance;
//     var account_two_starting_balance;
//     var account_one_ending_balance;
//     var account_two_ending_balance;
//
//     var amount = 10;
//
//     return MetaCoin.deployed().then(function(instance) {
//       meta = instance;
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_starting_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_starting_balance = balance.toNumber();
//       return meta.sendCoin(account_two, amount, {from: account_one});
//     }).then(function() {
//       return meta.getBalance.call(account_one);
//     }).then(function(balance) {
//       account_one_ending_balance = balance.toNumber();
//       return meta.getBalance.call(account_two);
//     }).then(function(balance) {
//       account_two_ending_balance = balance.toNumber();
//
//       assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
//       assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
//     });
//   });
// });
let changeRequestAddress;
let gitHash = "0x9a034128a329f4fb7a53043dd1d1e8f74bfc91fc";
let additionalInformation = "These are additional information";
let costs = 2400;
let estimation = 24;
let changerequest;

let State = {
    changeProposed: 0, changeManaged: 1, changeApproved: 2, changeRejected: 3, changeReleased: 4
};

contract('ChangeManager', function (accounts) {
    it("should create a new ChangeRequest", function () {
        return ChangeManager.deployed().then(function (changemanager) {
            return changemanager.createNewChangeRequest(gitHash, additionalInformation, costs, estimation);
        }).then(function (result) {
            result.logs.filter(log => log.event === "NewChangeRequest")
                .map(log => log.args)
                .forEach(args => {
                    changeRequestAddress = args._changeRequestAddress;
                    assert.equal(args._gitHash, gitHash, 'Correct git hash has not been returned');
                    assert.equal(args._additionalInformation, additionalInformation, 'Correct additional information have not been returned');
                    assert.equal(args._costs, costs, 'Corrects costs have not been returned');
                    assert.equal(args._estimation, estimation, 'Correct estimation has not been returned');
                    assert.isNotNull(changeRequestAddress, "ChangeRequest contract address was null");
                });
        });
    });

    it("should get the data of the newly created ChangeRequest", function () {
        changerequest = ChangeRequest.at(changeRequestAddress);
        return changerequest.viewChange().then(function (result) {
            assert.equal(result[0], gitHash, 'Correct git hash has not been returned');
            assert.equal(result[1], additionalInformation, 'Correct additional information have not been returned');
            assert.equal(result[2], costs, 'Corrects costs have not been returned');
            assert.equal(result[3], estimation, 'Correct estimation has not been returned');
        });
    });
    it("should vote the newly created ChangeRequest down", function () {
        return changerequest.managementVote(false, [], "This is the reason why the change request is being rejected", {from: accounts[0]})
            .then(function (result) {
                result.logs.filter(log => log.event === "NewVote")
                    .map(log => log.args)
                    .forEach(args => {
                        assert.equal(args._vote, false, 'The vote has not been downvoted');
                        assert.equal(args._currentState, State.changeRejected, 'The change has not been rejected');
                    });
            });
    });
    it("should not be able to vote on a downvoted ChangeRequest", function () {
        return changerequest.responsibleVote(true, "This is the reason why the change request is being rejected", {from: accounts[1]})
            .catch(error => {
                assert.include(error.message, 'revert', 'The vote has not been reverted');
            });
    });
});
