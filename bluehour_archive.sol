pragma solidity ^0.4.24;

//Safe Math Interface

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


//ERC Token Standard #20 Interface

contract ERC20Interface {
    function name() public view returns (string)
    function symbol() public view returns (string)
    function decimals() public view returns (uint8)
    function totalSupply() public view returns (uint256)
    function balanceOf(address _owner) public view returns (uint256 balance)
    function transfer(address _to, uint256 _value) public returns (bool success)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    function approve(address _spender, uint256 _value) public returns (bool success)
    function allowance(address _owner, address _spender) public view returns (uint256 remaining)

    event Transfer(address indexed _from, address indexed _to, uint256 _value)
    event Approval(address indexed _owner, address indexed _spender, uint256 _value)
}


//Contract function to receive approval and execute function in one call

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

//Actual token contract

contract Bluehour is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address public minter;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    mapping(address => uint) public rewards;
    mapping(address => mapping(address => uint)) public debt;

    constructor() public {
        minter = msg.sender;
        symbol = "BLHR";
        name = "Bluehour Token";
        decimals = 18;
        _totalSupply = 1 000 000 000, 000 000 000 000 000 000; //1 bil x 10^18
        balances[minter] = _totalSupply;
        emit Transfer(address(0), minter, _totalSupply);
    }

    function mint(uint amount) public returns (bool success) {
        require(msg.sender == minter);
        balances[msg.sender] = safeAdd(amount, balances[msg.sender]);
        _totalSupply = safeAdd(amount, _totalSupply);
        return true;
    }

    function stake(uint amount, uint32 movie_hash, address to) public returns (bool success) {
        // must have a way to verify length of staking time (should repay over 6 mo or something) (should it be projected or calculated?)
        // subtract from balances to prevent transfers, however how to re-add to balances (how to do this at a delayed rate)
        // make sure to fix debt so that it properly adds movie cost
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        debt[msg.sender] = safeAdd(balances[msg.sender], amount);
        staked_to[msg.sender][to]= safeAdd(balances[msg.sender], amount);
        return true;
    }

    function create movie(uint){
        //theoretically the movie create function
    }
    function unstake(address from) public returns (bool success) {
        //same as below but for a single address
        require(rewards[msg.sender] >= debt[msg.sender][from];
        //let the value of debt (cost of movie) be the same as the amount of BLHR staked on the movie? (possibly 5x, 1 movie return cycle)
        rewards[msg.sender] = safeSub(rewards[msg.sender], debt[msg.sender][from]);
        debt[msg.sender][from] = 0;
        return true;

    }

    function unstake2() public
    // unstake by paying rewards (which are locked and assigned a total and per-coin value)
    // public store every reward with block stored on
    // access block stored of 'stake to'
    // sum rewards given since
    // checksum against stake value

    // can still distribute usdc / usdt

    //contract distribute usdc with new function  -> redeem(uint amount)
    // cannot redeem the value of rewards before clearing your balance
    // split distribution between creators and bluehour by only sending creators half rewards


    // math written to determine how much bluehour should be minted due to excess rewards (to keep constant or to raise value over time) something like  surplus / (total rewards / totalsupply (current))
    // valuation is future based??

    // show total tokens staked
    // if user would receive\ less than min bluehour from distro -- cancel
    // pay out staking rewards once each block and add something to the pool each time

    /*1000 tokens total totalsupply
    500 tokens staked to 2 creators (alice, and bob) users 501...1000
    1000 dollars token reward issued
    every user has 1 token
    user 1... user500 receive 1 dollar each
    user 501... user 1000 receive 0 dollars
    alice receive 125 dollars
    bob receive 125 dollars
    250 tokens rewards
    user501 ... user 1000 have no more debt to alice and bob
    user1... user1000 receive 0.25 tokens

    users 1...user500 receive 1.25 tokens
    users 501...1000 receive 0.25 tokes
    */
    require(rewards[msg.sender] >= debt[msg.sender][from];
    //let the value of debt (cost of movie) be the same as the amount of BLHR staked on the movie? (possibly 5x, 1 movie return cycle)
    rewards[msg.sender] = safeSub(rewards[msg.sender], debt[msg.sender][from]);
    debt[msg.sender][from] = 0;
    return true;

    //distribute rewards to one whole bluehour (some multiple (round down)


    function burn(uint amount) public returns (bool success) {
        require(msg.sender == minter);
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        return true;
    }

    function totalSupply() public returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function () public payable {
        revert();
    }
}
