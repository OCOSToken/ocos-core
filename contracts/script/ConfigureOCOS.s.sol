// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "../contracts/core/OCOSRegistry.sol";
import "../contracts/core/ReserveManager.sol";
import "../contracts/core/RouterManager.sol";
import "../contracts/core/FeeController.sol";
import "../contracts/core/EmergencyController.sol";

contract ConfigureOCOS is Script {
    uint256 internal constant ETHEREUM = 1;
    uint256 internal constant BNB_CHAIN = 56;
    uint256 internal constant POLYGON = 137;
    uint256 internal constant AVALANCHE = 43114;
    uint256 internal constant ARBITRUM = 42161;
    uint256 internal constant OPTIMISM = 10;
    uint256 internal constant BASE = 8453;
    uint256 internal constant FANTOM = 250;
    uint256 internal constant ZKSYNC = 324;
    uint256 internal constant LINEA = 59144;
    uint256 internal constant SCROLL = 534352;

    uint256 internal constant TRON = 10002;
    uint256 internal constant SOLANA = 10001;
    uint256 internal constant APTOS = 10003;
    uint256 internal constant SUI = 10004;
    uint256 internal constant NEAR = 10005;
    uint256 internal constant COSMOS = 10006;
    uint256 internal constant CARDANO = 10009;
    uint256 internal constant POLKADOT = 10010;
    uint256 internal constant TON = 10007;
    uint256 internal constant BITCOIN = 10008;

    uint256 internal constant REQUIRED_RESERVE = 1 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address registryAddress = vm.envAddress("OCOS_REGISTRY");
        address auditLedgerAddress = vm.envAddress("OCOS_AUDIT_LEDGER");
        address treasuryAddress = vm.envAddress("OCOS_TREASURY");
        address reserveManagerAddress = vm.envAddress("OCOS_RESERVE_MANAGER");
        address liquidityVaultAddress = vm.envAddress("OCOS_LIQUIDITY_VAULT");
        address settlementEngineAddress = vm.envAddress("OCOS_SETTLEMENT_ENGINE");
        address routerManagerAddress = vm.envAddress("OCOS_ROUTER_MANAGER");
        address feeControllerAddress = vm.envAddress("OCOS_FEE_CONTROLLER");
        address emergencyControllerAddress = vm.envAddress("OCOS_EMERGENCY_CONTROLLER");

        OCOSRegistry registry = OCOSRegistry(registryAddress);
        ReserveManager reserveManager = ReserveManager(reserveManagerAddress);
        RouterManager routerManager = RouterManager(routerManagerAddress);
        FeeController feeController = FeeController(feeControllerAddress);
        EmergencyController emergencyController = EmergencyController(emergencyControllerAddress);

        vm.startBroadcast(deployerPrivateKey);

        registry.setContract(keccak256("AUDIT_LEDGER"), auditLedgerAddress);
        registry.setContract(keccak256("TREASURY"), treasuryAddress);
        registry.setContract(keccak256("RESERVE_MANAGER"), reserveManagerAddress);
        registry.setContract(keccak256("LIQUIDITY_VAULT"), liquidityVaultAddress);
        registry.setContract(keccak256("SETTLEMENT_ENGINE"), settlementEngineAddress);
        registry.setContract(keccak256("ROUTER_MANAGER"), routerManagerAddress);
        registry.setContract(keccak256("FEE_CONTROLLER"), feeControllerAddress);
        registry.setContract(keccak256("EMERGENCY_CONTROLLER"), emergencyControllerAddress);

        emergencyController.addModule(auditLedgerAddress);
        emergencyController.addModule(treasuryAddress);
        emergencyController.addModule(reserveManagerAddress);
        emergencyController.addModule(liquidityVaultAddress);
        emergencyController.addModule(settlementEngineAddress);
        emergencyController.addModule(routerManagerAddress);
        emergencyController.addModule(feeControllerAddress);

        _configureNetwork(reserveManager, routerManager, feeController, ETHEREUM, "Ethereum");
        _configureNetwork(reserveManager, routerManager, feeController, BNB_CHAIN, "BNB Chain");
        _configureNetwork(reserveManager, routerManager, feeController, POLYGON, "Polygon");
        _configureNetwork(reserveManager, routerManager, feeController, AVALANCHE, "Avalanche");
        _configureNetwork(reserveManager, routerManager, feeController, ARBITRUM, "Arbitrum");
        _configureNetwork(reserveManager, routerManager, feeController, OPTIMISM, "Optimism");
        _configureNetwork(reserveManager, routerManager, feeController, BASE, "Base");
        _configureNetwork(reserveManager, routerManager, feeController, TRON, "Tron");
        _configureNetwork(reserveManager, routerManager, feeController, SOLANA, "Solana");
        _configureNetwork(reserveManager, routerManager, feeController, FANTOM, "Fantom");
        _configureNetwork(reserveManager, routerManager, feeController, ZKSYNC, "zkSync");
        _configureNetwork(reserveManager, routerManager, feeController, LINEA, "Linea");
        _configureNetwork(reserveManager, routerManager, feeController, SCROLL, "Scroll");
        _configureNetwork(reserveManager, routerManager, feeController, APTOS, "Aptos");
        _configureNetwork(reserveManager, routerManager, feeController, SUI, "Sui");
        _configureNetwork(reserveManager, routerManager, feeController, NEAR, "NEAR");
        _configureNetwork(reserveManager, routerManager, feeController, COSMOS, "Cosmos");
        _configureNetwork(reserveManager, routerManager, feeController, CARDANO, "Cardano");
        _configureNetwork(reserveManager, routerManager, feeController, POLKADOT, "Polkadot");
        _configureNetwork(reserveManager, routerManager, feeController, TON, "TON");
        _configureNetwork(reserveManager, routerManager, feeController, BITCOIN, "Bitcoin Settlement Layer");

        vm.stopBroadcast();

        console2.log("OCOS Core configured successfully");
    }

    function _configureNetwork(
        ReserveManager reserveManager,
        RouterManager routerManager,
        FeeController feeController,
        uint256 networkId,
        string memory networkName
    ) internal {
        reserveManager.createNetworkReserve(networkId, networkName, REQUIRED_RESERVE);

        routerManager.registerRouter(networkId, networkName, address(0x000000000000000000000000000000000000dEaD));

        feeController.setFeeConfig(
            networkId,
            30,
            20,
            10,
            0,
            0,
            true
        );
    }
}
