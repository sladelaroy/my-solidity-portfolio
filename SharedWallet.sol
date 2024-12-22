// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract OurWallet {

    address payable owner;

    

    mapping(address => uint) public allowance;
    mapping (address => bool) public allowedToWithdraw;
    constructor () {
        owner = payable (msg.sender);
        allowedToWithdraw[msg.sender] = true;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "you are not the owner");
        _;
    }

    function deppositMoney () public payable {
        allowance[msg.sender] += msg.value;
    }

    function setAllowance(address _address, uint _amountAllowed) public onlyOwner {
        allowance[_address] += _amountAllowed;
        allowedToWithdraw[_address] = true;
    }

    function withdrawMoney(address payable _to, uint _amount) public {
        require(allowedToWithdraw[msg.sender], "you are not allowed to withdraw");
        require(allowance[msg.sender] >= _amount, "you cannot withdraw more than what you have");
        allowance[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
    receive() external payable { 

    }
}