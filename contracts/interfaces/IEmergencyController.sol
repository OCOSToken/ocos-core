// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IEmergencyController {
    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event GlobalEmergencyActivated(address indexed triggeredBy);
    event GlobalEmergencyResolved(address indexed resolvedBy);
    event ModulePaused(address indexed module);
    event ModuleUnpaused(address indexed module);

    function addModule(address module) external;

    function removeModule(address module) external;

    function activateGlobalEmergency() external;

    function resolveGlobalEmergency() external;

    function pauseModule(address module) external;

    function unpauseModule(address module) external;

    function getModules() external view returns (address[] memory);

    function globalEmergency() external view returns (bool);

    function isModule(address module) external view returns (bool);
}
