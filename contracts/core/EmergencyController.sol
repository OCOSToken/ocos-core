// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IPausableModule {
    function pause() external;
    function unpause() external;
}

contract EmergencyController is AccessControl {
    bytes32 public constant EMERGENCY_ADMIN_ROLE = keccak256("EMERGENCY_ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    bool public globalEmergency;

    address[] public modules;
    mapping(address => bool) public isModule;

    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event GlobalEmergencyActivated(address indexed triggeredBy);
    event GlobalEmergencyResolved(address indexed resolvedBy);
    event ModulePaused(address indexed module);
    event ModuleUnpaused(address indexed module);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(EMERGENCY_ADMIN_ROLE, admin);
        _grantRole(GUARDIAN_ROLE, admin);
    }

    function addModule(address module) external onlyRole(EMERGENCY_ADMIN_ROLE) {
        require(module != address(0), "Invalid module");
        require(!isModule[module], "Already module");

        modules.push(module);
        isModule[module] = true;

        emit ModuleAdded(module);
    }

    function removeModule(address module) external onlyRole(EMERGENCY_ADMIN_ROLE) {
        require(isModule[module], "Not module");

        isModule[module] = false;

        uint256 length = modules.length;

        for (uint256 i = 0; i < length; i++) {
            if (modules[i] == module) {
                modules[i] = modules[length - 1];
                modules.pop();
                break;
            }
        }

        emit ModuleRemoved(module);
    }

    function activateGlobalEmergency() external onlyRole(GUARDIAN_ROLE) {
        globalEmergency = true;

        uint256 length = modules.length;

        for (uint256 i = 0; i < length; i++) {
            if (isModule[modules[i]]) {
                IPausableModule(modules[i]).pause();
                emit ModulePaused(modules[i]);
            }
        }

        emit GlobalEmergencyActivated(msg.sender);
    }

    function resolveGlobalEmergency() external onlyRole(EMERGENCY_ADMIN_ROLE) {
        globalEmergency = false;

        uint256 length = modules.length;

        for (uint256 i = 0; i < length; i++) {
            if (isModule[modules[i]]) {
                IPausableModule(modules[i]).unpause();
                emit ModuleUnpaused(modules[i]);
            }
        }

        emit GlobalEmergencyResolved(msg.sender);
    }

    function pauseModule(address module) external onlyRole(GUARDIAN_ROLE) {
        require(isModule[module], "Not module");

        IPausableModule(module).pause();

        emit ModulePaused(module);
    }

    function unpauseModule(address module) external onlyRole(EMERGENCY_ADMIN_ROLE) {
        require(isModule[module], "Not module");

        IPausableModule(module).unpause();

        emit ModuleUnpaused(module);
    }

    function getModules() external view returns (address[] memory) {
        return modules;
    }
}
