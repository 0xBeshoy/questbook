// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract SmartBankAccount {
    uint256 totalContractBalance = 0;

    function getContractBalance() public view returns (uint256) {
        return totalContractBalance;
    }

    mapping(address => uint256) balances;
    mapping(address => uint256) depositTimestamps;

    function addBalance() public payable {
        balances[msg.sender] = msg.value;
        totalContractBalance = totalContractBalance + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
    }

    function getBalance(address userAddress) public view returns (uint256) {
        uint256 principal = balances[userAddress];
        uint256 timeElapsed = block.timestamp - depositTimestamps[userAddress]; //seconds
        return
            principal +
            uint256(
                (principal * 7 * timeElapsed) / (100 * 365 * 24 * 60 * 60)
            ) +
            1; //simple interest of 0.07%  per year
    }

    function withdraw() public payable {
        address payable withdrawTo = payable(msg.sender);
        uint256 amountToTransfer = getBalance(msg.sender);
        withdrawTo.transfer(amountToTransfer);
        totalContractBalance = totalContractBalance - amountToTransfer;
        balances[msg.sender] = 0;
    }

    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }
}
