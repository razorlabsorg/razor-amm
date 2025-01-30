# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= sparse
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 0x0133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a
AMM_ADDRESS ?= 0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile:
	aptos move compile \
	--save-metadata \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"

test:
	aptos move test \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--coverage

publish:
	aptos move deploy-object \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--address-name razor_amm

upgrade:
	aptos move upgrade-object \
	--address-name razor_amm \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)" \
	--object-address $(AMM_ADDRESS)

docs:
	aptos move document \
	--skip-fetch-latest-git-deps \
	--skip-attribute-checks \
	--named-addresses "razor_amm=$(DEV_ACCOUNT)"
