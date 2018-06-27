pragma solidity ^0.4.24;

import {ChangeTracker} from './ChangeTracker.sol';

// This contract represents a specific ChangeRequest
contract ChangeRequest is ChangeTracker {
    // Privileges
    address private _changeOwner;
    address private _constructionManager;

    // Change data
    bytes20 private _gitHash;
    string private _additionalInformation;
    uint256 private _costs;
    uint256 private _estimation;

    // Vote state
    State private _state;
    mapping(address => bool) private _allowedToVote;
    uint256 private _voteCount;
    string private _voteInfo;

    // This event gets propagated every time a new Vote happens and tracks the _currentChange.state and the _votesLeft
    event NewVote(
        address _voter,
        bool _vote,
        State _currentState,
        string _voteInfo,
        uint256 _votesLeft
    );

    constructor(
        bytes20 gitHash,
        string additionalInformation,
        uint256 costs,
        uint256 estimation,
        address changeOwner,
        address constructionManager
    ) public {
        _changeOwner = changeOwner;
        _constructionManager = constructionManager;

        _additionalInformation = additionalInformation;
        _gitHash = gitHash;
        _costs = costs;
        _estimation = estimation;

        _state = State.changeProposed;
    }

    // Function can only be run by the owner of the ChangeManager contract (construction manager). The construction
    // manager does the first review of the ChangeRequest, can reject it or employ the responsible parties who are
    // allowed to vote on the change.
    function managementVote(bool acceptChange, address[] responsibleParties, string rejectionReason)
    public
    {
        require(msg.sender == _constructionManager);
        require(_state == State.changeProposed);
        if (acceptChange) {
            _voteCount = responsibleParties.length;
            for (uint i = 0; i < responsibleParties.length; i++) {
                _allowedToVote[responsibleParties[i]] = true;
            }
            _state = State.changeManaged;
            emit NewVote(msg.sender, acceptChange, _state, "Management Vote", _voteCount);
        }
        else {
            _state = State.changeRejected;
            _voteInfo = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _state, _voteInfo, 0);
        }
    }

    // The allowed parties can vote. As soon as everyone has voted the ChangeRequest is either accepted or rejected
    // TODO: If it's rejected, the changeOwner can amend the ChangeRequest and restart the voting process.
    function responsibleVote(bool acceptChange, string rejectionReason) public {
        require(_state == State.changeManaged);
        require(_allowedToVote[msg.sender]);
        _allowedToVote[msg.sender] = false;
        if (!acceptChange) {
            _state = State.changeRejected;
            _voteInfo = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _state, _voteInfo, 0);
        }
        else {
            _voteCount = _voteCount - 1;
            if (_voteCount == 0) {
                _state = State.changeApproved;
                emit NewVote(msg.sender, acceptChange, _state, "Vote Finished", _voteCount);
            }
            else {
                emit NewVote(msg.sender, acceptChange, _state, "Responsible Vote", _voteCount);
            }
        }
    }

    function setVoteCount(uint256 voteCount, address setter) public {
        require(setter == _constructionManager);
        _voteCount = voteCount;
    }

    // Problem: Voting is not an atomic function ->
    //Can reduce vote without removing oneself from the allowedToVote list
    function reduceVoteCount(address setter) public {
        require(_allowedToVote[setter]);
        _voteCount = _voteCount - 1;
    }

    function getVoteCount() public view returns (uint256){return _voteCount;}

    // Only the manager is allowed to set allowance to vote
    function setAllowedToVote(address responsibleParty, address setter) public {
        require(setter == _constructionManager);
        _allowedToVote[responsibleParty] = true;
    }

    // Only manager and the responsible party itself are allowed to revoke allowance to vote
    function setNotAllowedToVote(address responsibleParty, address setter) public {
        require(setter == _constructionManager || setter == responsibleParty);
        _allowedToVote[responsibleParty] = false;
    }

    function isAllowedToVote(address party) public view returns (bool){
        return _allowedToVote[party];
    }

    // Problem: responsibleParty can just change the state without caring about voting
    function setState(State state, address setter) public {
        require(setter == _constructionManager || _allowedToVote[setter]);
        _state = state;
    }

    function getState() public view returns (State){return _state;}

    function setVoteInfo(string voteInfo, address setter) public {
        require(setter == _constructionManager || _allowedToVote[setter]);
        _voteInfo = voteInfo;
    }

    function getVoteInfo() public view returns (string){return _voteInfo;}

    // The ChangeRequest has been accepted and can be released.
    function releaseChange() public {
        require(_state == State.changeApproved);
        _state = State.changeReleased;
        emit NewVote(msg.sender, true, _state, "Released", 0);
    }

    // Returns the data of the change
    function viewChange() public view returns (bytes20 gitHash, string additionalInformation, uint256 costs, uint256 estimation) {
        return (_gitHash, _additionalInformation, _costs, _estimation);
    }

    // Returns the state of the change
    function viewState() public view returns (State state, uint256 votesLeft, string rejectionReason) {
        return (_state, _voteCount, _voteInfo);
    }
}
