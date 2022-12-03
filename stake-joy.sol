pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract StakingRewards {
using SafeERC20 for ERC20;
using SafeMath for uint256;

// Address of the JOY ERC20 token contract
address private joyTokenAddress;

// Address of the PTS ERC20 token contract
address private ptsTokenAddress;

// Mapping of staked JOY balances for each user
mapping(address => uint256) private stakedBalances;

// Mapping of staked JOY timestamps for each user
mapping(address => uint256) private stakedTimestamps;

// Mapping of rewards earned for each user
mapping(address => uint256) private rewardsEarned;

// Reward rate per second
uint256 private rewardRate;

// Constructor to initialize the contract
constructor(address joyToken, address ptsToken, uint256 rewardRatePerSecond) public {
    joyTokenAddress = joyToken;
    ptsTokenAddress = ptsToken;
    rewardRate = rewardRatePerSecond;
}

// Function to deposit JOY tokens and start staking
function deposit(uint256 amount) public {
    // Ensure that the user has enough JOY tokens
    ERC20(joyTokenAddress).safeTransferFrom(msg.sender, address(this), amount);

    // Update the staked balance and timestamp for the user
    stakedBalances[msg.sender] = stakedBalances[msg.sender].add(amount);
    stakedTimestamps[msg.sender] = now;
}

// Function to withdraw JOY tokens and stop staking
function withdraw(uint256 amount) public {
    // Ensure that the user has enough staked JOY tokens
    require(stakedBalances[msg.sender] >= amount, "Insufficient staked JOY balance");

    // Update the staked balance and timestamp for the user
    stakedBalances[msg.sender] = stakedBalances[msg.sender].sub(amount);
    stakedTimestamps[msg.sender] = 0;

    // Transfer the withdrawn amount of JOY tokens to the user
    ERC20(joyTokenAddress).safeTransfer(msg.sender, amount);
}

// Function to claim rewards earned from staking
function claimRewards() public {
    // Calculate the rewards earned by the user
    uint256 earned = rewardsEarned[msg.sender].add(rewardRate.mul(now.sub(stakedTimestamps[msg.sender])));

    // Transfer the rewards earned to the user
    ERC20(ptsTokenAddress).safeTransfer(msg.sender, earned);

    // Reset the rewards earned by the user
    rewardsEarned[msg.sender] = 0;
}