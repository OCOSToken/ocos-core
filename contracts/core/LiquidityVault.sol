// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LiquidityVault is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");
    bytes32 public constant VAULT_OPERATOR_ROLE = keccak256("VAULT_OPERATOR_ROLE");
    bytes32 public constant ALLOCATOR_ROLE = keccak256("ALLOCATOR_ROLE");

    mapping(address => uint256) public allocatedLiquidity;

    event Deposited(address indexed token, address indexed sender, uint256 amount);
    event Allocated(address indexed token, address indexed to, uint256 amount);
    event Released(address indexed token, uint256 amount);
    event Withdrawn(address indexed token, address indexed to, uint256 amount);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(VAULT_ADMIN_ROLE, admin);
        _grantRole(VAULT_OPERATOR_ROLE, admin);
        _grantRole(ALLOCATOR_ROLE, admin);
    }

    receive() external payable {
        emit Deposited(address(0), msg.sender, msg.value);
    }

    function depositERC20(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(token != address(0), "Invalid token");
        require(amount > 0, "Invalid amount");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(token, msg.sender, amount);
    }

    function allocate(
        address token,
        address to,
        uint256 amount
    ) external nonReentrant whenNotPaused onlyRole(ALLOCATOR_ROLE) {
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Invalid amount");

        if (token == address(0)) {
            require(address(this).balance - allocatedLiquidity[token] >= amount, "Insufficient native liquidity");
        } else {
            require(IERC20(token).balanceOf(address(this)) - allocatedLiquidity[token] >= amount, "Insufficient token liquidity");
        }

        allocatedLiquidity[token] += amount;

        emit Allocated(token, to, amount);
    }

    function release(address token, uint256 amount) external onlyRole(ALLOCATOR_ROLE) {
        require(amount > 0, "Invalid amount");
        require(allocatedLiquidity[token] >= amount, "Release exceeds allocation");

        allocatedLiquidity[token] -= amount;

        emit Released(token, amount);
    }

    function withdraw(
        address token,
        address payable to,
        uint256 amount
    ) external nonReentrant whenNotPaused onlyRole(VAULT_ADMIN_ROLE) {
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Invalid amount");

        if (token == address(0)) {
            require(address(this).balance - allocatedLiquidity[token] >= amount, "Insufficient native free balance");

            (bool success, ) = to.call{value: amount}("");
            require(success, "Native transfer failed");
        } else {
            require(IERC20(token).balanceOf(address(this)) - allocatedLiquidity[token] >= amount, "Insufficient token free balance");

            IERC20(token).safeTransfer(to, amount);
        }

        emit Withdrawn(token, to, amount);
    }

    function freeLiquidity(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance - allocatedLiquidity[token];
        }

        return IERC20(token).balanceOf(address(this)) - allocatedLiquidity[token];
    }

    function pause() external onlyRole(VAULT_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(VAULT_ADMIN_ROLE) {
        _unpause();
    }
}
