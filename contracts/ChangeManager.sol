pragma solidity ^0.4.24;

import {ChangeTracker} from './ChangeTracker.sol';
import {ChangeRequest} from './ChangeRequest.sol';

// This contracts serves as a ChangeRequest factory
contract ChangeManager is ChangeTracker{
    address private _constructionManager;
    ChangeRequest[] private _changes;
    mapping(bytes20 => ChangeRequest) _changeRequests;

    event NewChangeRequest(
        address _changeRequestAddress,
        bytes20 indexed _gitHash,
        string _additionalInformation,
        uint256 _costs,
        uint256 _estimation
    );

//    // This event gets propagated every time a new Vote happens and tracks the _currentChange.state and the _votesLeft
//    event NewVote(
//        address _voter,
//        bool _vote,
//        State _currentState,
//        string _voteInfo,
//        uint256 _votesLeft
//    );

    constructor() public {
        _constructionManager = msg.sender;
    }

    // Creates a new ChangeRequest contract and saves the address in _changes
    function createNewChangeRequest(
        bytes20 gitHash,
        string additionalInformation,
        uint256 costs,
        uint256 estimation
    )
    public
    {
        ChangeRequest changeRequest = new ChangeRequest(gitHash, additionalInformation, costs, estimation, msg.sender, _constructionManager);
        _changes.push(changeRequest);
        _changeRequests[gitHash] = changeRequest;
        emit NewChangeRequest(changeRequest, gitHash, additionalInformation, costs, estimation);
    }

    function managementVote(
        bytes20 gitHash,
        bool acceptChange,
        address[] responsibleParties,
        string voteInfo
    )
    public
    {
        _changeRequests[gitHash].managementVote(acceptChange, responsibleParties, voteInfo);
    }

    function responsibleVote(
        bytes20 gitHash,
        bool acceptChange,
        string voteInfo
    )
    public
    {
        _changeRequests[gitHash].responsibleVote(acceptChange, voteInfo);
    }

    // Returns the address of the ChangeRequest
    function getChangeRequestAddress(bytes20 gitHash)
    public
    view
    returns (address changeRequestAddress)
    {
        return _changeRequests[gitHash];
    }
}
