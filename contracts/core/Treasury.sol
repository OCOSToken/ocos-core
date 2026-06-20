// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Treasury is AccessControl, Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant TREASURY_ADMIN_ROLE = keccak256("TREASURY_ADMIN_ROLE");
    bytes32 public constant TREASURY_OPERATOR_ROLE = keccak256("TREASURY_OPERATOR_ROLE");

    event NativeReceived(address indexed sender, uint256 amount);
    event ERC20Deposited(address indexed token, address indexed sender, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed to, uint256 amount);
    event NativeWithdrawn(address indexed to, uint256 amount);

    constructor(address admin) Ownable(admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(TREASURY_ADMIN_ROLE, admin);
        _grantRole(TREASURY_OPERATOR_ROLE, admin);
    }

    receive() external payable {
        emit NativeReceived(msg.sender, msg.value);
    }

    function depositERC20(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(token != address(0), "Invalid token");
        require(amount > 0, "Invalid amount");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit ERC20Deposited(token, msg.sender, amount);
    }

    function withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) external nonReentrant whenNotPaused onlyRole(TREASURY_ADMIN_ROLE) {
        require(token != address(0), "Invalid token");
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Invalid amount");

        IERC20(token).safeTransfer(to, amount);

        emit ERC20Withdrawn(token, to, amount);
    }

    function withdrawNative(
        address payable to,
        uint256 amount
    ) external nonReentrant whenNotPaused onlyRole(TREASURY_ADMIN_ROLE) {
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = to.call{value: amount}("");
        require(success, "Native transfer failed");

        emit NativeWithdrawn(to, amount);
    }

    function pause() external onlyRole(TREASURY_OPERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(TREASURY_ADMIN_ROLE) {
        _unpause();
    }
}
