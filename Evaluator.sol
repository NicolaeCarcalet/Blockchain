// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Evaluator {
    string name;
    string expertiseCategory;

    constructor(string memory _name, string memory _expertiseCategory) public {
        name = _name;
        expertiseCategory = _expertiseCategory;
    }

    function getEvaluatorName() public view returns(string memory) {
        return name;
    }

    function getExpertise() public view returns(string memory) {
        return expertiseCategory;
    }
}