# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= sparse
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 0xfaded96b72a03b2ed9e2b2dc0bef0642d63e07fd7b1eeeac047188eb1ef34dd6
AMM_ADDRESS ?= 0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile:
	movement move compile \
	--save-metadata \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"

test:
	movement move test \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--coverage

publish-testnet:
	movement move create-object-and-publish-package \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--address-name razor_amm

publish-mainnet:
	movement move create-object-and-publish-package \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--address-name razor_amm \
	--profile mainnet

upgrade-testnet:
	movement move upgrade-object-package \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(AMM_ADDRESS)" \
	--object-address $(AMM_ADDRESS)

upgrade-mainnet:
	movement move upgrade-object-package \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(AMM_ADDRESS)" \
	--object-address $(AMM_ADDRESS) \
	--profile mainnet

docs:
	movement move document \
	--named-addresses "razor_amm=$(AMM_ADDRESS)"
