pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import { ChangeTracker } from './ChangeTracker.sol';
import { ChangeRequest } from './ChangeRequest.sol';

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

    // TODO: Use roles from SIMULTAN
    enum Role {
        constructionManager, architect, engineer, electrician, contractor
    }

    struct StakeHolder {
        address identity;
        Role role;
    }

    constructor() public {
        _constructionManager = msg.sender;
    }

    function createNewChangeRequest(
        bytes20 gitHash, string additionalInformation, uint256 costs, uint256 estimation
    ) public returns (ChangeRequest)
    {
        ChangeRequest changerequest = new ChangeRequest(gitHash, additionalInformation, costs, estimation, msg.sender);
        _changes.push(changerequest);
        emit NewChangeRequest(changerequest, gitHash, additionalInformation, costs, estimation);
    }
}
