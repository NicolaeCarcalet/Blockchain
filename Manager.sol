// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Manager {
    string name;

    constructor(string memory financerName) public {
        name = financerName;
    }

    function getManagerName() public view returns(string memory) {
        return name;
    }
}