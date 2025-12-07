// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Toolbox {
    address public owner;
    string  public status;
    bool    private locked; // simple reentrancy guard

    /* ========== Events ========== */
    event Deposit(address indexed sender, uint256 amount);
    event StatusChanged(address indexed who, string oldStatus, string newStatus);
    event ExecutedCall(address indexed target, uint256 value, bool success, bytes returnData);
    event Withdraw(address indexed to, uint256 amount);

    /* ========== Modifiers ========== */
    modifier onlyOwner() {
        require(msg.sender == owner, "Toolbox: not owner");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Toolbox: reentrant");
        locked = true;
        _;
        locked = false;
    }

    /* ========== Constructor ========== */
    constructor() {
        owner = msg.sender;
        status = "GUA MULAI!!!";
    }

    /* ========== Receive / Fallback ========== */
    // Receive is called when msg.data is empty (plain ETH transfer)
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Fallback is called when function not found or when calldata not empty
    fallback() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /* ========== State mutators ========== */
    function setStatus(string memory _newStatus) public nonReentrant {
        string memory old = status;
        status = _newStatus;
        emit StatusChanged(msg.sender, old, _newStatus);
    }

    /* Withdraw contract balance (owner only) */
    function withdraw(address payable _to, uint256 _amount) external onlyOwner nonReentrant {
        require(address(this).balance >= _amount, "Toolbox: insufficient balance");
        (bool sent,) = _to.call{value: _amount}("");
        require(sent, "Toolbox: send failed");
        emit Withdraw(_to, _amount);
    }

    /* Low-level call executor:
       - owner can call arbitrary function on any target address
       - returns raw bytes (and emits event)
       - use with extreme caution (this allows arbitrary interactions)
    */
    function execCall(address _target, bytes calldata _data, uint256 _value)
        external
        onlyOwner
        nonReentrant
        returns (bytes memory)
    {
        require(_target != address(0), "Toolbox: zero target");

        (bool success, bytes memory returnData) = _target.call{value: _value}(_data);
        emit ExecutedCall(_target, _value, success, returnData);

        require(success, "Toolbox: target call failed");
        return returnData;
    }

    /* ========== Helpers ========== */
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /* Allow owner transfer ownership (optional) */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Toolbox: zero address");
        owner = _newOwner;
    }
}
