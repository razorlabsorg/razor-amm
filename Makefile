# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= all
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839
AMM_ADDRESS ?= 0x190aae4e7b1b0bcecbe4c451179ac7e4a0a8ef4dad110f4947c59cb4d51fbca2

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile:
	aptos move compile \
	--skip-fetch-latest-git-deps \
	--save-metadata \
	--included-artifacts $(ARTIFACTS_LEVEL) \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"

test:
	aptos move test \
	--skip-fetch-latest-git-deps \
	--ignore-compile-warnings \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--coverage

publish:
	aptos move deploy-object \
	--skip-fetch-latest-git-deps \
	--included-artifacts ${ARTIFACTS_LEVEL} \
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
	--skip-fetch-latest-git-deps \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"
