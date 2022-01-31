// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Freelancer {
    string name;
    string expertiseCategory;
    uint reputation;

    constructor(string memory _name, string memory _expertiseCategory, uint _reputation) public {
        name = _name;
        expertiseCategory = _expertiseCategory;
        reputation = _reputation;
    }
}