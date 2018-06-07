pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import {ChangeTracker} from './ChangeTracker.sol';
import {ChangeRequest} from './ChangeRequest.sol';

// This contracts serves as a ChangeRequest factory
contract ChangeManager {
    address private _constructionManager;
    ChangeRequest[] private _changes;

    event NewChangeRequest(
        address _changeRequestAddress,
        bytes20 indexed _gitHash,
        string _additionalInformation,
        uint256 _costs,
        uint256 _estimation
    );

    constructor() public {
        _constructionManager = msg.sender;
    }

    // Creates a new ChangeRequest contract and saves the address in _changes
    function createNewChangeRequest(
        bytes20 gitHash, string additionalInformation, uint256 costs, uint256 estimation
    ) public
    {
        ChangeRequest changerequest = new ChangeRequest(gitHash, additionalInformation, costs, estimation, msg.sender);
        _changes.push(changerequest);
        emit NewChangeRequest(changerequest, gitHash, additionalInformation, costs, estimation);
    }
}
