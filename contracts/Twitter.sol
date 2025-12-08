// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract Trwitter {

  unit16 constant max-tweet = 280;

  struct Tweet {
    address author;
    string content;
    uint256 timestamp;
    uint256 like;
  }

  mapping(address => Tweet[]) public tweets;

  require(byte(_tweet).length <= max-tweet, "Tweet mwlebihi batas maksimum!");

  function createTweet(string memory _tweet) public {
    Tweet memory newTweet = Tweet({
      author: msg.sender,
      content: _tweet,
      timestamp: block.timestamp,
      like: 0
    });

    tweets[msg.sender].push(newTweet);
  }

  function getTweet(uint _i) public view returns(Tweet memory) {
    return tweets[_i];
  }

  function getAllTweet(address _owner) public view returns(Tweet[] memory) {
    return tweets[_owner];
  }
 
}