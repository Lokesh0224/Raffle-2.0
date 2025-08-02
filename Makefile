#This line imports environment variables from a .env file.
#The - prefix tells make to not error out if .env is missing, it just skips it silently.
-include .env

#Declares all, test, and deploy as phony targets — meaning they don't correspond to actual files.
#Without .PHONY, make might skip a target if a file with that name exists.
.PHONY: all test deploy

build :; forge build

test :; forge test

install :; forge install cyfin/foundry-devops@0.2.2 && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 && forge install foundry-rs/forge-std@v1.8.2 && forge install transmission11/solmate@v6

deploy-sepolia :
	@forge script scripts/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --account default --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv