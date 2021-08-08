pragma solidity ^0.4.24;

// This is an implementation of the ERC20 contract for testing purposes.

// Safe Math interface deals with arithmetic overflows by reverting the transaction.
contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ERC-20 interface is a standard for Fungible Tokens.
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// Contract function to receive approval and execute function in one call.
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// GilbertToken contract.
contract GilbertToken is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address TEST_ADDRESS = 0xbEDCD848307c3DD558849947137F756A794A060A; // Address for testing purposes.

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // Constructor. Redefine this for customization of a new token.
    constructor() public {
        symbol = "GRT";
        name = "Gilbert Ross Token";
        decimals = 2;
        _totalSupply = 100000;
        balances[TEST_ADDRESS] = _totalSupply;
        emit Transfer(address(0), TEST_ADDRESS, _totalSupply);
    }

    // Function for obtaining total supply of the token.
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)]; // Subtract owner balance.
    }

    // Function for checking the balance of an address.
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // Function to transfer tokens to an address from the total supply.
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Function to check if the total supply has enough tokens.
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // Function to transfer tokens between addresses.
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // Function to check if an address has enough tokens to perform a transaction.
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // Function to approve buying and spending tokens.
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // Function to prevent users from sending ETH directly to contract address.
    function () public payable {
        revert();
    }
}

/*

Gilbert Ross

*/