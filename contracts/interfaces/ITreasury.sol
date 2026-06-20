// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface ITreasury {
    event NativeReceived(address indexed sender, uint256 amount);
    event ERC20Deposited(address indexed token, address indexed sender, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed to, uint256 amount);
    event NativeWithdrawn(address indexed to, uint256 amount);

    function depositERC20(address token, uint256 amount) external;

    function withdrawERC20(address token, address to, uint256 amount) external;

    function withdrawNative(address payable to, uint256 amount) external;
}
