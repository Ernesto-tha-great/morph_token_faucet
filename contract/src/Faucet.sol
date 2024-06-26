// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TokenFaucet is Ownable, Pausable {
    IERC20 public token;
    uint256 public withdrawalAmount;
    uint256 public cooldownTime;

    mapping(address => uint256) public lastWithdrawTime;

    event Withdrawal(address indexed user, uint256 amount, uint256 time);
    event WithdrawalAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event CooldownTimeUpdated(uint256 oldCooldown, uint256 newCooldown);
    event TokenAddressUpdated(address oldToken, address newToken);

    constructor(address tokenAddress, uint256 initialWithdrawalAmount, uint256 initialCooldownTime) Ownable(msg.sender) {
        token = IERC20(tokenAddress);
        withdrawalAmount = initialWithdrawalAmount;
        cooldownTime = initialCooldownTime;
    }

    receive() external payable {}

    function withdraw() external whenNotPaused {
        require(token.balanceOf(address(this)) >= withdrawalAmount, "Insufficient funds in faucet");
        require(block.timestamp - lastWithdrawTime[msg.sender] >= cooldownTime, "Can only withdraw once per cooldown period");

        lastWithdrawTime[msg.sender] = block.timestamp;
        token.transfer(msg.sender, withdrawalAmount);

        emit Withdrawal(msg.sender, withdrawalAmount, block.timestamp);
    }

    function setWithdrawalAmount(uint256 newAmount) external onlyOwner {
        uint256 oldAmount = withdrawalAmount;
        withdrawalAmount = newAmount;
        emit WithdrawalAmountUpdated(oldAmount, newAmount);
    }

    function setCooldownTime(uint256 newCooldownTime) external onlyOwner {
        uint256 oldCooldownTime = cooldownTime;
        cooldownTime = newCooldownTime;
        emit CooldownTimeUpdated(oldCooldownTime, newCooldownTime);
    }

    function setTokenAddress(address newTokenAddress) external onlyOwner {
        address oldTokenAddress = address(token);
        token = IERC20(newTokenAddress);
        emit TokenAddressUpdated(oldTokenAddress, newTokenAddress);
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
