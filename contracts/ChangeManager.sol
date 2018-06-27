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

    // This event gets propagated every time a new Vote happens and tracks the _currentChange.state and the _votesLeft
    event NewVote(
        address _voter,
        bool _vote,
        State _currentState,
        string _voteInfo,
        uint256 _votesLeft
    );

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
        require(_changeRequests[gitHash].getState() == State.changeProposed);
        require(msg.sender == _constructionManager);

        ChangeRequest changeRequest = _changeRequests[gitHash];

        if (acceptChange) {
            changeRequest.setVoteCount(responsibleParties.length, msg.sender);
            for (uint i = 0; i < responsibleParties.length; i++) {
                changeRequest.setAllowedToVote(responsibleParties[i], msg.sender);
            }
            changeRequest.setState(State.changeManaged, msg.sender);

            emit NewVote(
                msg.sender,
                acceptChange,
                changeRequest.getState(),
                changeRequest.getVoteInfo(),
                changeRequest.getVoteCount()
            );
        }
        else {
            changeRequest.setState(State.changeRejected, msg.sender);
            changeRequest.setVoteInfo(voteInfo, msg.sender);
            emit NewVote(
                msg.sender,
                acceptChange,
                changeRequest.getState(),
                changeRequest.getVoteInfo(),
                0
            );
        }
    }

    function responsibleVote(
        bytes20 gitHash,
        bool acceptChange,
        string voteInfo
    )
    public
    {
        require(_changeRequests[gitHash].getState() == State.changeManaged);

        ChangeRequest changeRequest = _changeRequests[gitHash];

        require(changeRequest.isAllowedToVote(msg.sender));

        if (!acceptChange) {
            changeRequest.setState(State.changeRejected, msg.sender);
            changeRequest.setVoteInfo(voteInfo, msg.sender);
            emit NewVote(
                msg.sender,
                acceptChange,
                changeRequest.getState(),
                changeRequest.getVoteInfo(),
                0
            );
        }
        else {
            changeRequest.reduceVoteCount(msg.sender);
            if (changeRequest.getVoteCount() == 0) {
                changeRequest.setState(State.changeApproved, msg.sender);
                emit NewVote(
                    msg.sender,
                    acceptChange,
                    changeRequest.getState(),
                    "Vote Finished",
                    changeRequest.getVoteCount()
                );
            }
            else {
                emit NewVote(
                    msg.sender,
                    acceptChange,
                    changeRequest.getState(),
                    "Responsible Vote",
                    changeRequest.getVoteCount()
                );
            }
        }

        changeRequest.setNotAllowedToVote(msg.sender, msg.sender);
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
