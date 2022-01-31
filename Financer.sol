// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Financer {
    string name;

    constructor(string memory financerName) public {
        name = financerName;
    }

    function getFinancerName() public view returns(string memory) {
        return name;
    }
}