pragma solidity ^0.4.24;

contract ChangeTracker {
    enum State {
        changeProposed, changeManaged, changeApproved, changeRejected, changeReleased
    }

    struct Change {
        bytes20 gitHash;
        string additionalInformation;
        uint256 costs;
        uint256 estimation;
        State state;
    }
}
