// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IFanCommunity {
    function setStar(address user, uint fan) external;

    function getStar(address user) external view returns (uint256);
    
    function setPro(address user) external; 

    function makeuserfanPro(address user) external view returns (bool);
}

contract FanCommunity {
    uint fan1 = 1;
    uint fan2 = 2;
    uint fan3 = 3;
    uint fan4 = 4;

    mapping(address => uint) userToFanLevel;
    mapping(address => bool) isPro;

    function setStar(address user, uint fan) external {
        userToFanLevel[user] = fan;
    }

    function getStar(address user) external view returns (uint256) {
        return userToFanLevel[user];
    }

    function setPro(address user) public {
        isPro[user] = true;
    }

    function makeuserfanPro(address user) public view returns (bool) {
        return isPro[user];
    }
}
