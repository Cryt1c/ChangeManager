let ChangeManager = artifacts.require("./ChangeManager.sol");
let ChangeRequest = artifacts.require("./ChangeRequest.sol");

let gitHashFirst = "0x1a034128a329f4fb7a53043dd1d1e8f74bfc91fc";
let gitHashSecond = "0x29932f3915935d773dc8d52c292cadd81c81071d";
let additionalInformation = "These are additional information";
let costs = 2400;
let estimation = 24;

let changeRequestAddressFirst;
let changeRequestAddressSecond;
let changerequestFirst;
let changerequestSecond;

let State = {
    changeProposed: 0, changeManaged: 1, changeApproved: 2, changeRejected: 3, changeReleased: 4
};

contract('ChangeManager', function (accounts) {
    it("should create a new ChangeRequest", function () {
        return ChangeManager.deployed().then(function (changemanager) {
            return changemanager.createNewChangeRequest(gitHashFirst, additionalInformation, costs, estimation);
        }).then(function (result) {
            result.logs.filter(log => log.event === "NewChangeRequest")
                .map(log => log.args)
                .forEach(args => {
                    // console.log("Args1: ", args);
                    changeRequestAddressFirst = args._changeRequestAddress;
                    assert.equal(args._gitHash, gitHashFirst, 'Correct git hash has not been returned');
                    assert.equal(args._additionalInformation, additionalInformation, 'Correct additional information have not been returned');
                    assert.equal(args._costs, costs, 'Corrects costs have not been returned');
                    assert.equal(args._estimation, estimation, 'Correct estimation has not been returned');
                    assert.isNotNull(changeRequestAddressFirst, "ChangeRequest contract address was null");
                });
        });
    });

    it("should get the data of the newly created ChangeRequest", function () {
        changerequestFirst = ChangeRequest.at(changeRequestAddressFirst);
        return changerequestFirst.viewChange().then(function (result) {
            assert.equal(result[0], gitHashFirst, 'Correct git hash has not been returned');
            assert.equal(result[1], additionalInformation, 'Correct additional information have not been returned');
            assert.equal(result[2], costs, 'Corrects costs have not been returned');
            assert.equal(result[3], estimation, 'Correct estimation has not been returned');
        });
    });

    it("should vote the newly created ChangeRequest down", function () {
        return changerequestFirst.managementVote(false, [], "This is the reason why the change request is being rejected", {from: accounts[0]})
            .then(function (result) {
                result.logs.filter(log => log.event === "NewVote")
                    .map(log => log.args)
                    .forEach(args => {
                        assert.equal(args._vote, false, 'The vote has not been downvoted');
                        assert.equal(args._currentState, State.changeRejected, 'The change has not been rejected');
                        assert.equal(args._votesLeft, 0, 'The votes have not been reduced to 0');
                    });
            });
    });

    it("should not be able to vote on a downvoted ChangeRequest", function () {
        return changerequestFirst.responsibleVote(true, "This is the reason why the change request is being rejected", {from: accounts[1]})
            .catch(error => {
                assert.include(error.message, 'revert', 'The vote has not been reverted');
            });
    });

    it("should create a new ChangeRequest and be accepted by all parties", function () {
        return ChangeManager.deployed().then(function (changemanager) {
            return changemanager.createNewChangeRequest(gitHashSecond, additionalInformation, costs, estimation);
        }).then(function (result) {

            result.logs.filter(log => log.event === "NewChangeRequest")
                .map(log => log.args)
                .forEach(args => {
                    // console.log("Args2: ", args);
                    changeRequestAddressSecond = args._changeRequestAddress;
                });

            changerequestSecond = ChangeRequest.at(changeRequestAddressSecond);
            return changerequestSecond.managementVote(true, [accounts[1], accounts[2]], "", {from: accounts[0]})
                .then(function (result) {
                    result.logs.filter(log => log.event === "NewVote")
                        .map(log => log.args)
                        .forEach(args => {
                            // console.log("Args3: ", args);
                            assert.equal(args._currentState, State.changeManaged, 'The change has not been rejected');
                        });
                    changerequestSecond.responsibleVote(true, "", {from: accounts[4]})
                        .catch(error => {
                            assert.include(error.message, 'revert', 'An unallowed party was able to vote');
                        });
                    changerequestSecond.responsibleVote(true, "", {from: accounts[2]})
                        .then();
                    changerequestSecond.responsibleVote(true, "", {from: accounts[1]})
                        .then(function (result) {
                            result.logs.filter(log => log.event === "NewVote")
                                .map(log => log.args)
                                .forEach(args => {
                                    console.log("Args5: ", args);
                                });
                        });
                    changerequestSecond.releaseChange().then(function (result) {
                        result.logs.filter(log => log.event === "NewVote")
                            .map(log => log.args)
                            .forEach(args => {
                                console.log("Args5: ", args);
                            });
                    });
                });
        });
    });
});
