// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ETHFaucet is Ownable, Pausable {
    uint256 public constant WITHDRAWAL_AMOUNT = 0.01 ether;
    uint256 public cooldownTime;

    mapping(address => uint256) public lastWithdrawTime;

    event Withdrawal(address indexed user, uint256 amount, uint256 time);
    event CooldownTimeUpdated(uint256 oldCooldown, uint256 newCooldown);

    constructor(uint256 initialCooldownTime) Ownable(msg.sender) {
        cooldownTime = initialCooldownTime;
    }

    receive() external payable {}

    function withdraw() external whenNotPaused {
        require(address(this).balance >= WITHDRAWAL_AMOUNT, "Insufficient funds in faucet");
        require(block.timestamp - lastWithdrawTime[msg.sender] >= cooldownTime, "Can only withdraw once per cooldown period");

        lastWithdrawTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(WITHDRAWAL_AMOUNT);

        emit Withdrawal(msg.sender, WITHDRAWAL_AMOUNT, block.timestamp);
    }

    function setCooldownTime(uint256 newCooldownTime) external onlyOwner {
        uint256 oldCooldownTime = cooldownTime;
        cooldownTime = newCooldownTime;
        emit CooldownTimeUpdated(oldCooldownTime, newCooldownTime);
    }

    function pauseFaucet() external onlyOwner {
        _pause();
    }

    function unpauseFaucet() external onlyOwner {
        _unpause();
    }

    function getRemainingCooldownTime(address user) external view returns (uint256) {
        if (block.timestamp - lastWithdrawTime[user] >= cooldownTime) {
            return 0;
        } else {
            return cooldownTime - (block.timestamp - lastWithdrawTime[user]);
        }
    }
}
