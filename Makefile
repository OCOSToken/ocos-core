install:
	forge install foundry-rs/forge-std --no-commit
	forge install OpenZeppelin/openzeppelin-contracts --no-commit

build:
	forge build

test:
	forge test -vvv

coverage:
	forge coverage

gas:
	forge test --gas-report

fmt:
	forge fmt

snapshot:
	forge snapshot

clean:
	forge clean

slither:
	slither contracts

deploy-sepolia:
	forge script script/DeployOCOS.s.sol:DeployOCOS \
	--rpc-url $$SEPOLIA_RPC_URL \
	--broadcast \
	--verify

configure-sepolia:
	forge script script/ConfigureOCOS.s.sol:ConfigureOCOS \
	--rpc-url $$SEPOLIA_RPC_URL \
	--broadcast
