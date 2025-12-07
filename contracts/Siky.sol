// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

contract Siky {

  string public name = "Siky Coin";
  string public symbol = "SIKY";
  uint public decimals = 18;
  uint public  totalSuply; 

  mapping(address => uint) public balances;

  event Transfer(address indexed from, address indexed to, uint amount);

  constructor() {
    totalSuply =  1000000 * (10 ** uint(decimals));
    balances[msg.sender] = totalSuply;
    emit Transfer(address(0), msg.sender, totalSuply);
  }

  // cek saldo
  function balanceOf(address account) public view returns (uint) {
    return balances[account];
  }

  function transfer(address to, uint amount) public returns (bool) {
    require(balances[msg.sender] >= amount, "Your balance is insufficient to make this transaction");

    balances[msg.sender] -= amount;
    balances[to] += amount;

    emit Transfer(msg.sender, to, amount);
    return true;
  }
}