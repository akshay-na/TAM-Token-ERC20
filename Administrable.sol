// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract Administrable {
    address private _admin;

    event AdminshipTransferred(
        address indexed currentAdmin,
        address indexed newAdmin
    );

    constructor() {
        _admin = msg.sender;
        emit AdminshipTransferred(address(0), _admin);
    }

    function admin() public view returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only admin can perform this action");
        _;
    }

    function tranferAdminship(address newAdmin) public onlyAdmin {
        emit AdminshipTransferred(msg.sender, newAdmin);
        _admin = newAdmin;
    }
}
