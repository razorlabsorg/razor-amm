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
AMM_ADDRESS ?= 0x1e4b27a50145d09792b14db6ca1e88b907aa7c96d7f85f8b9b463a8bdfc48ab2

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
