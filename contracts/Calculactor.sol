// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Calculator {
    uint256 result = 0;

    function tambah(uint256 num) public {
        result += num;
    }

    function kurang(uint256 num) public {
        result -= num;
    }

    function kali(uint256 num) public {
        result *= num;
    }

    function get() public view returns(uint256) {
        return result;
    }
}