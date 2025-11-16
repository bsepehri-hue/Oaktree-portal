// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * L2B ERC-20 Token
 * - Fixed supply: 100,000,000 L2B (18 decimals)
 * - Full ERC-20 compliance
 */
contract L2BToken {
    // Metadata
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    // State
    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @param _name "ListToBid"
     * @param _symbol "L2B"
     * @param _initialSupply initial supply in wei (18 decimals)
     */
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;

        totalSupply = _initialSupply;
        _balances[msg.sender] = _initialSupply;

        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // Public ERC-20 functions
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= value, "ERC20: insufficient allowance");

        _transfer(from, to, value);
        unchecked {
            _approve(from, msg.sender, currentAllowance - value);
        }
        return true;
    }

    // Internal helpers
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC20: transfer from zero");
        require(to != address(0), "ERC20: transfer to zero");

        uint256 fromBal = _balances[from];
        require(fromBal >= value, "ERC20: insufficient balance");

        unchecked {
            _balances[from] = fromBal - value;
        }
        _balances[to] += value;

        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from zero");
        require(spender != address(0), "ERC20: approve to zero");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
