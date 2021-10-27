// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./Administrable.sol";
import "./TAM_Token.sol";

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//TODO: inherit ERC20 once import is working

contract MyTokenAdvanced is MyToken, Administrable {
    mapping(address => bool) private _frozenAccount;
    mapping(address => uint256) private _pendingWithdrawals;

    uint256 private _sellPrice = 1; // ether per token
    uint256 private _buyPrice = 1; // ether per token

    event FrozenFund(address indexed target, bool frozen);
    event PriceChange(uint256 newBuyPrice, uint256 newSellPrice);

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 decimalUints,
        address newAdmin
    ) MyToken(0, tokenName, tokenSymbol, decimalUints) {
        if (newAdmin != address(0) && newAdmin != msg.sender)
            tranferAdminship(newAdmin);

        setBalance(newAdmin, initialSupply);
        setTotalSupply(initialSupply);
    }

    function buyPrice() public view returns (uint256) {
        return _buyPrice;
    }

    function sellPrice() public view returns (uint256) {
        return _sellPrice;
    }

    function setPrice(uint256 newBuyPrice, uint256 newSellPrice)
        public
        onlyAdmin
    {
        require(newBuyPrice > 0);
        require(newSellPrice > 0);

        _buyPrice = newBuyPrice;
        _sellPrice = newSellPrice;
        emit PriceChange(newBuyPrice, newSellPrice);
    }

    function mintToken(address target, uint256 mintedAmount) public onlyAdmin {
        require(
            (balanceOf(target) + mintedAmount) > balanceOf(target),
            "Addition Overflow"
        );
        require(
            (totalSupply() + mintedAmount) > totalSupply(),
            "Addition Overflow"
        );

        setBalance(target, balanceOf(target) + mintedAmount);
        setTotalSupply(totalSupply() + mintedAmount);
        emit Tranfer(address(0), target, mintedAmount);
    }

    function freezAccount(address target, bool freeze) public onlyAdmin {
        require(target != address(0), "Cannot froze a zero account");
        _frozenAccount[target] = freeze;
        emit FrozenFund(target, freeze);
    }

    function tranfer(address receiver, uint256 amount)
        public
        override
        returns (bool)
    {
        require(receiver != address(0), "The receiver address cannot be zero");
        require(
            balanceOf(msg.sender) >= amount,
            "The sender has insufficient balance in the account"
        );
        require(
            balanceOf(receiver) + amount > balanceOf(receiver),
            "Addition overflow found in receiver account"
        );
        require(!_frozenAccount[msg.sender], "Senders account is Frozen");

        setBalance(msg.sender, balanceOf(msg.sender) - amount);
        setBalance(receiver, balanceOf(receiver) + amount);
        emit Tranfer(msg.sender, receiver, amount);
        return true;
    }

    function tranferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) public override returns (bool) {
        require(sender != address(0), "The sender address cannot be zero");
        require(receiver != address(0), "The receiver address cannot be zero");
        require(
            amount <= allowance(sender, msg.sender),
            "Allownce is not enough"
        );
        require(
            balanceOf(sender) >= amount,
            "The sender has insufficient balance in the account"
        );
        require(
            balanceOf(receiver) + amount > balanceOf(receiver),
            "Addition overflow found in receiver account"
        );
        require(!_frozenAccount[sender], "Senders account is Frozen");

        setBalance(sender, balanceOf(sender) - amount);
        setAllowance(
            sender,
            msg.sender,
            allowance(sender, msg.sender) - amount
        );
        setBalance(receiver, balanceOf(receiver) + amount);
        emit Tranfer(sender, receiver, amount);
        return true;
    }

    function buy() public payable {
        uint256 amount = (msg.value / (1 ether)) / _buyPrice;
        address thisContractAddress = address(this);

        require(
            balanceOf(thisContractAddress) >= amount,
            "Contract does not have enough token"
        );
        require(
            balanceOf(msg.sender) + amount > balanceOf(msg.sender),
            "Addition overflow found in receiver account"
        );

        setBalance(
            thisContractAddress,
            (balanceOf(thisContractAddress) - amount)
        );
        setBalance(msg.sender, (balanceOf(msg.sender) + amount));
        emit Tranfer(thisContractAddress, msg.sender, amount);
    }

    function sell(uint256 amount) public {
        address thisContractAddress = address(this);

        require(
            balanceOf(msg.sender) >= amount,
            "Seller does not have enough token"
        );
        require(
            balanceOf(thisContractAddress) + amount >
                balanceOf(thisContractAddress),
            "Addition overflow found in receiver account"
        );

        setBalance(msg.sender, (balanceOf(msg.sender) - amount));
        setBalance(
            thisContractAddress,
            (balanceOf(thisContractAddress) + amount)
        );
        uint256 saleProceed = amount * _sellPrice * (1 ether);
        _pendingWithdrawals[msg.sender] += saleProceed;
        emit Tranfer(msg.sender, thisContractAddress, amount);
    }

    function withdraw() public {
        uint256 amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
