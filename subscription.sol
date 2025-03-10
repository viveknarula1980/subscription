// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Subs {
    address public owner;
    uint256 public constant SUBSCRIPTION_FEE = 0.001 ether;
    uint256 public constant DURATION = 30 days;

    mapping(address => uint256) public subscriptionStart;  // Stores the start time of subscription
    mapping(address => uint256) public subscriptions;      // Stores the expiry time of subscription

    event Subscribed(address indexed user, uint256 startTime, uint256 expiryTime);
    event Refund(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function subscribe() external payable {
        require(msg.value >= SUBSCRIPTION_FEE, "Insufficient funds");

        address payable recipient = payable(Replace with actual wallet address of recepient);

        // Send only the required subscription fee to the recipient
        (bool success, ) = recipient.call{value: SUBSCRIPTION_FEE}("");
        require(success, "Transfer failed");

        uint256 excessAmount = msg.value - SUBSCRIPTION_FEE;

        // Refund excess amount to sender if overpaid
        if (excessAmount > 0) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: excessAmount}("");
            require(refundSuccess, "Refund failed");
            emit Refund(msg.sender, excessAmount);
        }

        uint256 currentTime = block.timestamp;

        if (currentTime >= subscriptions[msg.sender]) {
            subscriptionStart[msg.sender] = currentTime;
            subscriptions[msg.sender] = currentTime + DURATION;
        } else {
            subscriptions[msg.sender] += DURATION;
        }

        emit Subscribed(msg.sender, subscriptionStart[msg.sender], subscriptions[msg.sender]);
    }

    function isSubscribed(address _user) external view returns (bool) {
        return block.timestamp < subscriptions[_user];
    }

    function getSubscriptionDetails(address _user) external view returns (uint256 startTime, uint256 expiryTime) {
        return (subscriptionStart[_user], subscriptions[_user]);
    }

    // Only owner can withdraw mistakenly sent funds from the contract
    function withdrawExcessFunds(address _withdraw) external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance > 0, "No excess funds available");
        payable(_withdraw).transfer(address(this).balance);
    }
}
