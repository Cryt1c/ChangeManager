let ChangeManager = artifacts.require("./ChangeManager.sol");
let ChangeRequest = artifacts.require("./ChangeRequest.sol");

let gitHashSecond = "0x29932f3915935d773dc8d52c292cadd81c81071d";
let additionalInformation = "These are additional information";
let costs = 2400;
let estimation = 24;

let changeRequestAddressSecond;
let changerequestSecond;

let State = {
    changeProposed: 0, changeManaged: 1, changeApproved: 2, changeRejected: 3, changeReleased: 4
};

contract('AsyncAwaitChangeManager', function (accounts) {
    it("should test async/await", async function () {

        // Create new ChangeRequest
        let changemanager = await ChangeManager.deployed();
        let result = await changemanager.createNewChangeRequest(gitHashSecond, additionalInformation, costs, estimation);
        result.logs.filter(log => log.event === "NewChangeRequest")
            .map(log => log.args)
            .forEach(args => {
                // console.log("Args2: ", args);
                changeRequestAddressSecond = args._changeRequestAddress;
            });
        changerequestSecond = ChangeRequest.at(changeRequestAddressSecond);

        // Manage the new ChangeRequest and set Account 1 + 2 as responsible Parties
        result = await changerequestSecond.managementVote(true, [accounts[1], accounts[2]], "", {from: accounts[0]})
        result.logs.filter(log => log.event === "NewVote")
            .map(log => log.args)
            .forEach(args => {
                // console.log("Args3: ", args);
                assert.equal(args._currentState, State.changeManaged, 'The change has not been rejected');
            });

        // Illegally try to vote from Account 4
        changerequestSecond.responsibleVote(true, "", {from: accounts[4]})
            .catch(error => {
                assert.include(error.message, 'revert', 'An unallowed party was able to vote');
            });

        // Accept change using Account 1 + 2
        await changerequestSecond.responsibleVote(true, "", {from: accounts[2]});
        result = await changerequestSecond.responsibleVote(true, "", {from: accounts[1]});
        result.logs.filter(log => log.event === "NewVote")
            .map(log => log.args)
            .forEach(args => {
                // console.log("Args5: ", args);
            });

        // Release the Change
        result = await changerequestSecond.releaseChange().then(function (result) {
            result.logs.filter(log => log.event === "NewVote")
                .map(log => log.args)
                .forEach(args => {
                    // console.log("Args5: ", args);
                });
        });
    })
});
