pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import {ChangeTracker} from './ChangeTracker.sol';

contract ChangeRequest is ChangeTracker{
    Change private _currentChange;
    address private _changeOwner;
    address private _constructionManager;
    mapping(address => bool) private _allowdToVote;
    uint256 private _voteCount;
    State private _currentState;
    string private _rejectionReason;

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
        _constructionManager = manager;
        _changeOwner = msg.sender;
        _currentState = State.changeProposed;
    }

    function viewChange() public view returns (bytes20, string, uint256, uint256) {
        return (_currentChange.gitHash, _currentChange.additionalInformation, _currentChange.costs, _currentChange.estimation);
    }

    function managementVote(bool acceptChange, address[] responsibleParties, string rejectionReason)
    public
    {
        require(msg.sender == _constructionManager);
        require(_currentState == State.changeProposed);
        if (acceptChange) {
            _voteCount = responsibleParties.length;
            for (uint i = 0; i < responsibleParties.length; i++) {
                _allowdToVote[responsibleParties[i]] = true;
            }
            _currentState = State.changeManaged;
            emit NewVote(msg.sender, acceptChange, _currentState, "Management Vote", _voteCount);
        }
        else {
            _currentState = State.changeRejected;
            _rejectionReason = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _currentState, _rejectionReason, 0);
        }
    }

    function responsibleVote(bool acceptChange, string rejectionReason) public {
        require(_currentState == State.changeManaged);
        require(_allowdToVote[msg.sender]);
        _allowdToVote[msg.sender] = false;
        if (!acceptChange) {
            _currentState = State.changeRejected;
            _rejectionReason = rejectionReason;
            emit NewVote(msg.sender, acceptChange, _currentState, _rejectionReason, 0);
        }
        else {
            _voteCount = _voteCount - 1;
            if (_voteCount == 0) {
                _currentState = State.changeApproved;
                emit NewVote(msg.sender, acceptChange, _currentState, "Vote Finished", _voteCount);
            }
            else {
                emit NewVote(msg.sender, acceptChange, _currentState, "Responsible Vote", _voteCount);
            }
        }
    }

    function releaseChange() public {
        require(_currentState == State.changeApproved);
        _currentState = State.changeReleased;
        emit NewVote(msg.sender, true, _currentState, "Released", 0);
    }
}
