// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentSavingsWallet {
    struct Transaction {
        uint256 amount;
        string txType; // "Deposit" or "Withdrawal"
        uint256 timestamp;
    }

    // sate variables
    address public owner;
    uint256 public minimumDeposit;
    uint256 public withdrawTimeLock;


    mapping(address => uint256) private balances;
    mapping(address => Transaction[]) private transactionHistory;
    mapping(address => uint256) private lastDepositTime;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event MinimumDepositUpdated(uint256 newAmount);
    event TimeLockUpdated(uint256 newTimeLock);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner allowed");
        _;
    }

    constructor(uint256 _minimumDeposit, uint256 _timeLock){
        owner = msg.sender;
        minimumDeposit = _minimumDeposit;
        withdrawTimeLock = _timeLock;
    }




    // Deposit ETH into the wallet
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");

        balances[msg.sender] += msg.value;

        transactionHistory[msg.sender].push(
            Transaction(msg.value, "Deposit", block.timestamp)
        );

        emit Deposited(msg.sender, msg.value);
    }

    // Withdraw ETH from the wallet
    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");



        transactionHistory[msg.sender].push(
            Transaction(amount, "Withdrawal", block.timestamp)
        );

        emit Withdrawn(msg.sender, amount);
    }

    // Check user balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTransactionHistory()
        public
        view
        returns (Transaction[] memory)
    {
        return transactionHistory[msg.sender];
    }

    //owner functions
    function setMinimumDeposit(uint256 newMininum) public onlyOwner{
        minimumDeposit = newMininum;
        emit MinimumDepositUpdated(newMininum);
    }
}
