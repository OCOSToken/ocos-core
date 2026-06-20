// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface ILiquidityVault {
    event Deposited(address indexed token, address indexed sender, uint256 amount);
    event Allocated(address indexed token, address indexed to, uint256 amount);
    event Released(address indexed token, uint256 amount);
    event Withdrawn(address indexed token, address indexed to, uint256 amount);

    function depositERC20(address token, uint256 amount) external;

    function allocate(address token, address to, uint256 amount) external;

    function release(address token, uint256 amount) external;

    function withdraw(address token, address payable to, uint256 amount) external;

    function freeLiquidity(address token) external view returns (uint256);

    function allocatedLiquidity(address token) external view returns (uint256);
}
