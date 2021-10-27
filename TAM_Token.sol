// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract MyToken {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    event Tranfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 decimalUnits
    ) {
        _balances[msg.sender] = initialSupply;
        _totalSupply = initialSupply;
        _decimals = decimalUnits;
        _symbol = tokenSymbol;
        _name = tokenName;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function setTotalSupply(uint256 totalAmount) internal {
        _totalSupply = totalAmount;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function setBalance(address account, uint256 balance) internal {
        _balances[account] = balance;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowance[owner][spender];
    }

    function setAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _allowance[owner][spender] = amount;
    }

    function tranfer(address receiver, uint256 amount)
        public
        virtual
        returns (bool)
    {
        require(receiver != address(0), "The receiver address cannot be zero");
        require(
            _balances[msg.sender] >= amount,
            "The sender has insufficient balance in the account"
        );
        require(
            _balances[receiver] + amount > _balances[receiver],
            "Addition overflow found in receiver account"
        );
        _balances[msg.sender] -= amount;
        _balances[receiver] += amount;
        emit Tranfer(msg.sender, receiver, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        require(spender != address(0), "The Spender address cannot be zero");
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function tranferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) public virtual returns (bool) {
        require(sender != address(0), "The sender address cannot be zero");
        require(receiver != address(0), "The receiver address cannot be zero");
        require(
            amount <= _allowance[sender][receiver],
            "Allownce is not enough"
        );
        require(
            _balances[sender] >= amount,
            "The sender has insufficient balance in the account"
        );
        require(
            _balances[receiver] + amount > _balances[receiver],
            "Addition overflow found in receiver account"
        );

        _balances[sender] -= amount;
        _allowance[sender][msg.sender] -= amount;
        _balances[receiver] += amount;
        emit Tranfer(sender, receiver, amount);
        return true;
    }
}
