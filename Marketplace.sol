// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Token.sol";
import "./Financer.sol";
import "./Manager.sol";
import "./Evaluator.sol";
import "./Freelancer.sol";
import "./Task.sol";
import "./CrowdFunding.sol";

contract Marketplace {
    mapping(Task => CrowdFunding) openToFinanceTasks;
    mapping(string => Task) openToFinanceTasksNameMapping;
    mapping(Task => Evaluator) tasksEvaluators;
    Task[] taskForWork;

    Manager[] managers;
    Freelancer[] freelancers;
    Evaluator[] evaluators;
    Financer[] financers;

    CustomToken tokenPool;

    constructor() {
        tokenPool = new CustomToken(99999);
    }

    function addManager(string memory name) public {
        managers.push(new Manager(name));
    }

    function getManagers() public view returns(Manager[] memory) {
        return managers;
    }

    function addFreelancer(string memory name, string memory expertiseCategory, uint reputation) public {
        if (reputation < 1 || reputation > 10) {
            revert("Invalid reputation given, valid reputation value must be in range [1, 10]");
        }
        freelancers.push(new Freelancer(name, expertiseCategory, reputation));
    }

    function getFreelancers() public view returns(Freelancer[] memory) {
        return freelancers;
    }

    function addEvaluator(string memory name, string memory expertiseCategory) public {
        evaluators.push(new Evaluator(name, expertiseCategory));
    }

    function getEvaluators() public view returns(Evaluator[] memory) {
        return evaluators;
    }

    function addFinancer(string memory name, uint tokenAmount) public {
        Financer financer = new Financer(name);
        financers.push(financer);
        tokenPool.transfer(address(financer), tokenAmount); 
    }

    function getFinancers() public view returns(Financer[] memory) {
        return financers;
    }

    function createTask(string memory description, string memory managerName, uint freelancerReward, uint evaluatorReward, string memory expertiseCategory) public {
        if(!isManagerPresent(managerName)) {
            revert("Invalid manager used!");
        }
        Task task = new Task(description, expertiseCategory, freelancerReward, evaluatorReward, managerName);
        openToFinanceTasks[task] = new CrowdFunding(freelancerReward + evaluatorReward);
        openToFinanceTasksNameMapping[description] = task;
    }

    function isManagerPresent(string memory managerName) private view returns(bool) {
        for(uint i = 0; i < managers.length; i++) {
            if(compareStrings(managers[i].getManagerName(), managerName)) {
                return true;
            }
        }
        return false;
    }

    function financeTask(string memory financerName, string memory taskDescription, uint amount) public {
        if (!isFinancerPreset(financerName)) {
            revert("Invalid financer name or task description");
        }
        Financer financer = getFinancer(financerName);
        Task task = openToFinanceTasksNameMapping[taskDescription];
        if (openToFinanceTasks[task].hasReachedAmount()) {
            revert("Financing for this task has ended");
        } else {
            openToFinanceTasks[task].donate(address(financer), financerName, amount);
            tokenPool.transfer(address(openToFinanceTasks[task]), amount);
        }
    }

    function chooseEvaluator(string memory managerName, string memory evaluatorName, string memory taskDescription) public {
        Task task = openToFinanceTasksNameMapping[taskDescription];
        if (!openToFinanceTasks[task].hasReachedAmount()) {
            revert("Only already financed tasks can be assigned an evaluator");
        }
        if (!compareStrings(task.getManagerName(), managerName)) {
            revert("Only the manager that created the task can assign it an evaluator");
        }

        Evaluator evaluator = getEvaluator(evaluatorName);
        if (!compareStrings(evaluator.getExpertise(), task.getExpertise())) {
            revert("The evaluator's expertise must be in line with the task's");
        }
        tasksEvaluators[task] = evaluator;
        taskForWork.push(task);
    }

    function getEvaluator(string memory evaluatorName) private view returns(Evaluator) {
        for(uint i = 0; i < evaluators.length; i++) {
            if(compareStrings(evaluators[i].getEvaluatorName(), evaluatorName)) {
                return evaluators[i];
            }
        }
    }

    function withdrawFinancing(string memory financerName, string memory taskDescription, uint amount) public {
        if (!isFinancerPreset(financerName)) {
            revert("Invalid financer name or task description");
        }
        Financer financer = getFinancer(financerName);
        Task task = openToFinanceTasksNameMapping[taskDescription];
        if (openToFinanceTasks[task].hasReachedAmount()) {
            revert("Financing for this task has ended");
        } else {
            tokenPool.transfer(address(financer), amount);
            openToFinanceTasks[task].withdraw(address(financer), amount);
        }
    }

    function getFinancerBalance(string memory financerName) public view returns(uint) {
        return tokenPool.balanceOf(address(getFinancer(financerName)));
    }

    function cancelTask(string memory managerName, string memory taskDescription) public {
        Task task = openToFinanceTasksNameMapping[taskDescription];
        if (openToFinanceTasks[task].hasReachedAmount()) {
            revert("A task can be canceled only if it wasn't financed already");
        }
        CrowdFunding crowd = openToFinanceTasks[task];
        for (uint i = 0; i < financers.length; i++) {
            if (crowd.donorExists(address(financers[i]))) {
                tokenPool.transfer(address(financers[i]), crowd.getDonorsAmount(address(financers[i])));
            }
        }
    }

    function isFinancerPreset(string memory financerName) private view returns(bool) {
        for(uint i = 0; i < financers.length; i++) {
            if(compareStrings(financers[i].getFinancerName(), financerName)) {
                return true;
            }
        }
        return false;
    }

    function getFinancer(string memory financerName) private view returns(Financer) {
        for(uint i = 0; i < financers.length; i++) {
            if(compareStrings(financers[i].getFinancerName(), financerName)) {
                return financers[i];
            }
        }
    }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function initMarketplace() public {
        addManager("Franz Klausmann");
        addManager("Mario Rossi");
        addFreelancer("BestJavaDev", "Java", 9);
        addFreelancer("python", "Python", 5);
        addEvaluator("Evaluator1", "test");
        addEvaluator("Evaluator2", "Java");
        addFinancer("Financer1", 10);
        addFinancer("Financer2", 20);
    }
}