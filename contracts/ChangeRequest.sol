pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import {ChangeTracker} from './ChangeTracker.sol';

// This contract represents a specific ChangeRequest
contract ChangeRequest is ChangeTracker {
    Change private _currentChange;
    address private _changeOwner;
    address private _constructionManager;
    mapping(address => bool) private _allowdToVote;
    uint256 private _voteCount;
    string private _rejectionReason;

    // This event gets propagated every time a new Vote happens and tracks the _currentChange.state and the _votesLeft
    event NewVote(
        address _voter,
        bool _vote,
        State _currentState,
        string _voteInfo,
        uint256 _votesLeft
    );

    constructor(bytes20 gitHash, string additionalInformation, uint256 costs, uint256 estimation, address manager) public {
        _currentChange.additionalInformation = additionalInformation;
        _currentChange.gitHash = gitHash;
        _currentChange.costs = costs;
        _currentChange.estimation = estimation;
        _currentChange.state = State.changeProposed;

        _constructionManager = manager;
        _changeOwner = msg.sender;
    }

    // Returns the data of the change
    function viewChange() public view returns (bytes20, string, uint256, uint256, State) {
        return (_currentChange.gitHash, _currentChange.additionalInformation, _currentChange.costs, _currentChange.estimation, _currentChange.state);
    }

    // Function can only be run by the owner of the ChangeManager contract (construction manager). The construction
    // manager does the first review of the ChangeRequest, can reject it or employ the responsible parties who are
    // allowed to vote on the change.
    function managementVote(bool acceptChange, address[] responsibleParties, string rejectionReason)
    public
    {
        require(msg.sender == _constructionManager);
        require(_currentChange.state == State.changeProposed);
        if (acceptChange) {
            _voteCount = responsibleParties.length;
            for (uint i = 0; i < responsibleParties.length; i++) {
                _allowdToVote[responsibleParties[i]] = true;
            }
            _currentChange.state = State.changeManaged;
            emit NewVote(msg.sender, acceptChange, _currentChange.state, "Management Vote", _voteCount);
        }
        else {
            _currentChange.state = State.changeRejected;
            _rejectionReason = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _currentChange.state, _rejectionReason, 0);
        }
    }

    // The allowed parties can vote. As soon as everyone has voted the ChangeRequest is either accepted or rejected
    // TODO: If it's rejected, the changeOwner can amend the ChangeRequest and restart the voting process.
    function responsibleVote(bool acceptChange, string rejectionReason) public {
        require(_currentChange.state == State.changeManaged);
        require(_allowdToVote[msg.sender]);
        _allowdToVote[msg.sender] = false;
        if (!acceptChange) {
            _currentChange.state = State.changeRejected;
            _rejectionReason = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _currentChange.state, _rejectionReason, 0);
        }
        else {
            _voteCount = _voteCount - 1;
            if (_voteCount == 0) {
                _currentChange.state = State.changeApproved;
                emit NewVote(msg.sender, acceptChange, _currentChange.state, "Vote Finished", _voteCount);
            }
            else {
                emit NewVote(msg.sender, acceptChange, _currentChange.state, "Responsible Vote", _voteCount);
            }
        }
    }

    // The ChangeRequest has been accepted and can be released.
    function releaseChange() public {
        require(_currentChange.state == State.changeApproved);
        _currentChange.state = State.changeReleased;
        emit NewVote(msg.sender, true, _currentChange.state, "Released", 0);
    }
}
