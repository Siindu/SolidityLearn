// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

contract Start {
    string public status = "GUA MULAI!!!";
    
    function setStatus(string memory _newStatus) public {

        status = _newStatus;
    } 
}