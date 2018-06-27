import * as web3 from 'web3';

let ChangeManager = artifacts.require('./ChangeManager.sol');
let ChangeRequest = artifacts.require('./ChangeRequest.sol');

let gitHashFirst = '0x1a034128a329f4fb7a53043dd1d1e8f74bfc91fc';
let gitHashSecond = '0x29932f3915935d773dc8d52c292cadd81c81071d';
let additionalInformation = 'These are additional information';
let costs = 2400;
let estimation = 24;

let changeRequestAddressFirst;
let changeRequestAddressSecond;
let changemanager;
let changerequestFirst;
let changerequestSecond;

let State = {
    changeProposed: 0, changeManaged: 1, changeApproved: 2, changeRejected: 3, changeReleased: 4
};

contract('ChangeManager Voting', function (accounts) {
    it('should have emitted event with contract address', async function () {
        changemanager = await  ChangeManager.deployed();
        let event = changemanager.allEvents({fromBlock: 0, toBlock: 'latest'});

        event.watch(function (error, result) {
            if (!error && result.event === 'NewChangeManager') {
                assert.isNotNull(result.args._changeManagerAddress);
            }
        });
    });
    it('should create a new ChangeRequest', async function () {
        let changemanager = await  ChangeManager.deployed();
        let result = await changemanager.createNewChangeRequest(gitHashFirst, additionalInformation, costs, estimation);
        result.logs.filter(log => log.event === 'NewChangeRequest')
            .map(log => log.args)
            .forEach(args => {
                changeRequestAddressFirst = args._changeRequestAddress;
                assert.equal(args._gitHash, gitHashFirst, 'Correct git hash has not been returned');
                assert.equal(args._additionalInformation, additionalInformation, 'Correct additional information have not been returned');
                assert.equal(args._costs, costs, 'Correct costs have not been returned');
                assert.equal(args._estimation, estimation, 'Correct estimation has not been returned');
                assert.isNotNull(changeRequestAddressFirst, 'ChangeRequest contract address was null');
            });
    });

    it('should get the data of the newly created ChangeRequest', async function () {
        changerequestFirst = ChangeRequest.at(changeRequestAddressFirst);
        let result = await changerequestFirst.viewChange();
        assert.equal(result[0], gitHashFirst, 'Correct git hash has not been returned');
        assert.equal(result[1], additionalInformation, 'Correct additional information have not been returned');
        assert.equal(result[2], costs, 'Corrects costs have not been returned');
        assert.equal(result[3], estimation, 'Correct estimation has not been returned');
    });

    it('should vote the newly created ChangeRequest down', async function () {
        let result = await changemanager.managementVote(gitHashFirst, false, [], 'This is the reason why the change request is being rejected', {from: accounts[0]});
        result.logs.filter(log => log.event === 'NewVote')
            .map(log => log.args)
            .forEach(args => {
                assert.equal(args._vote, false, 'The vote has not been downvoted');
                assert.equal(args._currentState, State.changeRejected, 'The change has not been rejected');
                assert.equal(args._votesLeft, 0, 'The votes have not been reduced to 0');
            });
    });

    // it('should not be able to vote on a downvoted ChangeRequest', async function () {
    //     await changemanager.responsibleVote(gitHashFirst, true, 'This is the reason why the change request is being rejected', {from: accounts[1]})
    //         .catch(error => {
    //             assert.include(error.message, 'revert', 'The vote has not been reverted');
    //         });
    // });
    //
    // it('should create a new ChangeRequest and be accepted by all parties', async function () {
    //     // Create new ChangeRequest
    //     let changemanager = await ChangeManager.deployed();
    //     let result = await changemanager.createNewChangeRequest(gitHashSecond, additionalInformation, costs, estimation);
    //     result.logs.filter(log => log.event === 'NewChangeRequest')
    //         .map(log => log.args)
    //         .forEach(args => {
    //             assert.isNotNull(args._changeRequestAddress, 'ChangeRequest address was not null');
    //             changeRequestAddressSecond = args._changeRequestAddress;
    //         });
    //
    //     // Manage the new ChangeRequest and set Account 1 + 2 as responsible Parties
    //     result = await changemanager.managementVote(gitHashSecond, true, [accounts[1], accounts[2]], '', {from: accounts[0]});
    //     result.logs.filter(log => log.event === 'NewVote')
    //         .map(log => log.args)
    //         .forEach(args => {
    //             assert.equal(args._currentState, State.changeManaged, 'The change has been rejected');
    //         });
    //
    //     // Illegally try to vote from Account 4
    //     changemanager.responsibleVote(gitHashSecond, true, '', {from: accounts[4]})
    //         .catch(error => {
    //             assert.include(error.message, 'revert', 'An unallowed party was not able to vote');
    //         });
    //
    //     // Accept change using Account 1 + 2
    //     await changemanager.responsibleVote(gitHashSecond, true, '', {from: accounts[2]});
    //     result = await changemanager.responsibleVote(gitHashSecond, true, '', {from: accounts[1]});
    //     result.logs.filter(log => log.event === 'NewVote')
    //         .map(log => log.args)
    //         .forEach(args => {
    //             assert.equal(args._currentState, State.changeApproved, 'The change has been approved');
    //             assert.equal(args._votesLeft, 0, 'There are 0 votes left')
    //         });

        // // Release the Change
        // result = await changerequestSecond.releaseChange().then(function (result) {
        //     result.logs.filter(log => log.event === 'NewVote')
        //         .map(log => log.args)
        //         .forEach(args => {
        //             assert.equal(args._currentState, State.changeReleased, 'The change has been released');
        //         });
        // });
    // });
});
