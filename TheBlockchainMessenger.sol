// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract BlockchainMessenger {
    uint public changeCounter;

    address public owner;

    string public message;

    constructor() {
        owner = msg.sender;
    }

    function changeMessage(string memory _message) public {
        if (owner == msg.sender) {
            message = _message;
            changeCounter++;
        }
        
    }
}