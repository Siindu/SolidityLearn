SPDX-License-Identifier: MIT;

pragma solidity >=0.8.2 <0.9.0;

contract Trwitter {

  mapping(address => string) public tweets;

  function createTweet(string memory _tweet) public {
    tweets[msg.sender] = _tweet;
  }

  function getTweet(address -owner) public view returns(string memory) {
    return tweets[_owner];
  }
 
}