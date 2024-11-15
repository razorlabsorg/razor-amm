# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= all
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31
AMM_ADDRESS ?= 0xdb50057c09b9915cf9f88ad3f4c9278eb369788c63186ef1c4624a5af645d177

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile-amm:
	aptos move compile \
	--skip-fetch-latest-git-deps \
	--save-metadata \
	--included-artifacts $(ARTIFACTS_LEVEL) \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"

test-amm:
	aptos move test \
	--skip-fetch-latest-git-deps \
	--ignore-compile-warnings \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--coverage

publish-amm:
	aptos move deploy-object \
	--skip-fetch-latest-git-deps \
	--included-artifacts none \
	--profile razor_amm \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--address-name razor_amm

upgrade-amm:
	aptos move upgrade-object \
	--skip-fetch-latest-git-deps \
	--profile razor_amm \
	--address-name razor_amm \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--object-address $(AMM_ADDRESS)

doc-amm:
	aptos move document \
	--skip-fetch-latest-git-deps \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"
