#[test_only]
module razor_amm::factory_tests {
  use std::signer;
  use std::vector;

  use aptos_std::math64::pow;

  use aptos_framework::account;

  use razor_amm::factory;
  use razor_amm::pair;
  use razor_amm::controller_tests;
  use razor_amm::test_coins;
  use razor_amm::razor_token;
  use razor_amm::usdc_token;

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  public fun create_pair(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    factory::create_pair(bob, razor_address, usdc_address);

    let expected_pair_address = factory::get_pair(razor_address, usdc_address);
    let created_pair_address = pair::liquidity_pool_address(razor_metadata, usdc_metadata);
    assert!(created_pair_address == expected_pair_address, 0);    

    let all_pairs = factory::all_pairs();
    let first_pair = *vector::borrow(&all_pairs, 0);
    assert!(first_pair == expected_pair_address, 1);

    let all_pairs_length = factory::all_pairs_length();
    assert!(all_pairs_length == 1, 2);
  }

  #[test(deployer = @razor_amm)]
  public fun test_initialization(deployer: &signer) {
    controller_tests::setup_test_with_genesis(deployer);
    assert!(factory::is_initialized(), 0);
  }

  #[test(deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 1)] // amm_errors::identical_addresses
  public fun test_create_pair_identical_tokens(
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    let razor_address = razor_token::razor_token_address();
    factory::create_pair(bob, razor_address, razor_address);
  }

  #[test(deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 2)] // amm_errors::pair_exists
  public fun test_create_duplicate_pair(
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    factory::create_pair(bob, razor_address, usdc_address);
    // Try to create the same pair again
    factory::create_pair(bob, razor_address, usdc_address);
  }

  #[test(deployer = @razor_amm, bob = @bob)]
  public fun test_get_pair_nonexistent(
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    let pair_address = factory::get_pair(razor_address, usdc_address);
    assert!(pair_address == @0x0, 0);
  }

  #[test(deployer = @razor_amm, bob = @bob)]
  public fun test_pair_exists_functions(
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    // Test before pair creation
    assert!(!factory::pair_exists(razor_metadata, usdc_metadata), 0);
    assert!(!factory::pair_exists_safe(razor_metadata, usdc_metadata), 1);

    // Create pair
    factory::create_pair(bob, razor_address, usdc_address);
    let pair_address = factory::get_pair(razor_address, usdc_address);

    // Test after pair creation
    assert!(factory::pair_exists(razor_metadata, usdc_metadata), 2);
    assert!(factory::pair_exists_safe(razor_metadata, usdc_metadata), 3);
    assert!(factory::pair_exists_for_frontend(pair_address), 4);
  }

  #[test(deployer = @razor_amm, bob = @bob)]
  public fun test_all_pairs_paginated(
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    // Create pair
    factory::create_pair(bob, razor_address, usdc_address);
    let pair_address = factory::get_pair(razor_address, usdc_address);

    // Test pagination
    let pairs = factory::all_pairs_paginated(0, 1);
    assert!(vector::length(&pairs) == 1, 0);
    assert!(*vector::borrow(&pairs, 0) == pair_address, 1);

    // Test pagination with start beyond length
    let empty_pairs = factory::all_pairs_paginated(1, 1);
    assert!(vector::length(&empty_pairs) == 0, 2);

    // Test pagination with large limit
    let all_pairs = factory::all_pairs_paginated(0, 100);
    assert!(vector::length(&all_pairs) == 1, 3);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  public fun test_admin_functions(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);

    // Test pause/unpause
    factory::pause(admin);
    factory::unpause(admin);

    // Test admin management
    let bob_address = signer::address_of(bob);
    factory::set_admin(admin, bob_address);
    factory::claim_admin(bob);
  }
}