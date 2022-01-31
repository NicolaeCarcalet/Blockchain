// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Manager.sol";

contract Task {
    string description;
    uint freelancerReward;
    uint evaluatorReward;
    string expertiseCategory;
    string assignedManager;

    constructor(string memory _description, string memory _expertiseCategory, uint _freelancerReward, uint _evaluatorReward, string memory _assignedManager) public {
        description = _description;
        expertiseCategory = _expertiseCategory;
        evaluatorReward = _evaluatorReward;
        freelancerReward = _freelancerReward;
        assignedManager = _assignedManager;
    }

    function getTaskDescription() public view returns(string memory) {
        return description;
    }

    function getManagerName() public view returns(string memory) {
        return assignedManager;
    }

    function getExpertise() public view returns(string memory) {
        return expertiseCategory;
    }
}