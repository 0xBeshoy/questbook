// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface cETH {
    // define functions of COMPOUND we'll be using

    function mint() external payable; // to deposit to compound

    function redeem(uint256 redeemTokens) external returns (uint256); // to withdraw from compound

    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract SmartBankAccount {
    uint256 totalContractBalance = 0;

    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    receive() external payable {}

    function getContractBalance() public view returns (uint256) {
        return totalContractBalance;
    }

    mapping(address => uint256) balances;
    mapping(address => uint256) depositTimestamps;

    function addBalance() public payable {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        totalContractBalance = totalContractBalance + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;

        // send ethers to mint()
        ceth.mint{value: msg.value}();
    }

    function getBalance(address userAddress) public view returns (uint256) {
        return (ceth.balanceOf(userAddress) * ceth.exchangeRateStored()) / 1e18;
    }

    function withdraw(uint256 _amountToTransfer) public payable {
        uint256 amountToTransfer = _amountToTransfer;

        ceth.redeem(amountToTransfer);
        totalContractBalance = totalContractBalance - amountToTransfer;
        balances[msg.sender] = balances[msg.sender] - amountToTransfer;
        payable(msg.sender).transfer(amountToTransfer);
    }

    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }
}
