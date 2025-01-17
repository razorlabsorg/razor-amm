# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= none
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 0x0133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a
AMM_ADDRESS ?= 0xb4511e6e7a2ef84cb97123641aba2b750ad58a55428d327c8a90592743f434e6

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile:
	aptos move compile \
	--skip-fetch-latest-git-deps \
	--move-2 \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"

test:
	aptos move test \
	--skip-fetch-latest-git-deps \
	--ignore-compile-warnings \
	--move-2 \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--coverage

publish:
	aptos move deploy-object \
	--move-2 \
	--skip-fetch-latest-git-deps \
	--included-artifacts sparse \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--address-name razor_amm

upgrade:
	aptos move upgrade-object \
	--skip-fetch-latest-git-deps \
	--address-name razor_amm \
	--included-artifacts none \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--object-address $(AMM_ADDRESS)

docs:
	aptos move document \
	--move-2 \
	--skip-fetch-latest-git-deps \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"
