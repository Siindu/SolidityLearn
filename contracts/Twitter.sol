// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19 <0.9.0;

contract Trwitter {

  unit16 constant maxTweet = 280;

  struct Tweet {
    uint256 id;
    address author;
    string content;
    uint256 timestamp;
    uint256 like;
  }

  mapping(address => Tweet[]) public tweets;

  require(byte(_tweet).length <= maxTweet, "Tweet mwlebihi batas maksimum!");

  function createTweet(string memory _tweet) public {
    Tweet memory newTweet = Tweet({
      id: tweets[msg.sender].length,
      author: msg.sender,
      content: _tweet,
      timestamp: block.timestamp,
      like: 0
    });

    tweets[msg.sender].push(newTweet);
  }

  function likeTweet(address author, uint256 id) external {
    require(tweets[author][id].id == id, "Tweet tidak tersedia");
    
    tweets[author][id].likes++;
  }

  function unlikeTweet(address author, uint256 id) external {
    require(tweets[author][id].id == id, "Tweet tidak tersedia");
    require(tweets[author][id],likes >= 0, "Tweet tidak memiliki Like");
    
    tweets[author][id].likes--;
  }

  function getTweet(uint _i) public view returns(Tweet memory) {
    return tweets[_i];
  }

  function getAllTweet(address _owner) public view returns(Tweet[] memory) {
    return tweets[_owner];
  }
 
}