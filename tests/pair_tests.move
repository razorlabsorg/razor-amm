#[test_only]
module razor_amm::amm_pair_tests {
  use std::signer;

  use aptos_framework::account;
  use aptos_framework::object;
  use aptos_framework::primary_fungible_store;

  use aptos_std::math64::{pow, mul_div};

  use razor_amm::amm_controller_tests;
  use razor_amm::amm_factory;
  use razor_amm::test_coins;
  use razor_amm::razor_token;
  use razor_amm::usdc_token;
  use razor_amm::amm_pair;
  use razor_amm::amm_controller;

  use razor_libs::sort;

  const MINIMUM_LIQUIDITY: u64 = 1000;

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_mint(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let (tokenA, tokenB) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&tokenA), object::object_address(&tokenB));

    let created_pair = amm_pair::liquidity_pool(tokenA, tokenB);
    
    let token0_amount = 1 * pow(10, 8);
    let token1_amount = 4 * pow(10, 8);

    let expected_liquidity = 2 * pow(10, 8);

    let token0_to_withdraw = primary_fungible_store::withdraw(bob, tokenA, token0_amount);
    let token1_to_withdraw = primary_fungible_store::withdraw(bob, tokenB, token1_amount);

    amm_pair::mint(bob, token0_to_withdraw, token1_to_withdraw, @bob);

    let lp_total_supply = amm_pair::lp_token_supply(created_pair);
    let bob_lp_balance = amm_pair::lp_balance_of(@bob, created_pair);
    let pool_balance0 = amm_pair::balance0(created_pair);
    let pool_balance1 = amm_pair::balance1(created_pair);

    assert!(pool_balance0 == token0_amount, 2);

    assert!(lp_total_supply == (expected_liquidity as u128), 0);
    assert!(bob_lp_balance == (expected_liquidity - MINIMUM_LIQUIDITY), 1);
    assert!(pool_balance0 == token0_amount, 2);
    assert!(pool_balance1 == token1_amount, 3);

    let (reserve0, reserve1, _) = amm_pair::get_reserves(created_pair);
    assert!(reserve0 == token0_amount, 4);
    assert!(reserve1 == token1_amount, 5);
  }
  
  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_burn(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let (tokenA, tokenB) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&tokenA), object::object_address(&tokenB));

    let created_pair = amm_pair::liquidity_pool(tokenA, tokenB);

    let token0_amount = 3 * pow(10, 8);
    let token1_amount = 3 * pow(10, 8);

    let expected_liquidity = 3 * pow(10, 8);

    let token0_to_withdraw = primary_fungible_store::withdraw(bob, tokenA, token0_amount);
    let token1_to_withdraw = primary_fungible_store::withdraw(bob, tokenB, token1_amount);

    amm_pair::mint(bob, token0_to_withdraw, token1_to_withdraw, @bob);

    let (tokenA_to_withdraw, tokenB_to_withdraw) = amm_pair::burn(bob, created_pair, expected_liquidity - MINIMUM_LIQUIDITY);

    primary_fungible_store::deposit(@bob, tokenA_to_withdraw);
    primary_fungible_store::deposit(@bob, tokenB_to_withdraw);

    let bob_lp_balance = amm_pair::lp_balance_of(@bob, created_pair);
    let pair_total_supply = amm_pair::lp_token_supply(created_pair);
    let pool_balance0 = amm_pair::balance0(created_pair);
    let pool_balance1 = amm_pair::balance1(created_pair);

    let total_supply_token0 = razor_token::total_supply();
    let total_supply_token1 = usdc_token::total_supply();

    let bob_token0_balance = razor_token::balance_of(@bob);
    let bob_token1_balance = usdc_token::balance_of(@bob);

    assert!(bob_lp_balance == 0, 0);
    assert!(pair_total_supply == (MINIMUM_LIQUIDITY as u128), 1);
    assert!(pool_balance0 == 1000, 2);
    assert!(pool_balance1 == 1000, 3);

    assert!(bob_token0_balance == ((total_supply_token0 as u64) - 1000), 4);
    assert!(bob_token1_balance == ((total_supply_token1 as u64) - 1000), 5);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_swap(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    // Initial setup
    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    // Create pair and add initial liquidity
    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Initial reserves check
    let (initial_reserve0, initial_reserve1, _) = amm_pair::get_reserves(pair);
    assert!(initial_reserve0 == token0_amount, 0);
    assert!(initial_reserve1 == token1_amount, 1);

    // Test Scenario 1: Swap token0 for token1
    let amount_in = 1 * pow(10, 8);
    let token0_swap = primary_fungible_store::withdraw(bob, token0, amount_in);
    let empty_token = primary_fungible_store::withdraw(bob, token1, 0);

    let (token0_out, token1_out) = amm_pair::swap(
        bob,
        pair,
        token0_swap,
        0,
        empty_token,
        1 * pow(10, 8),
        @bob
    );

    primary_fungible_store::deposit(@bob, token0_out);
    primary_fungible_store::deposit(@bob, token1_out);

    let (reserve0, reserve1, _) = amm_pair::get_reserves(pair);
    assert!(reserve0 == token0_amount + amount_in, 2);
    assert!(reserve0 > 0 && reserve1 > 0, 3);
    
    // Verify k = reserve0 * reserve1 remains constant (minus fees)
    let k_before = initial_reserve0 * initial_reserve1;
    let k_after = reserve0 * reserve1;
    
    assert!(k_after > k_before, 4); // Should increase
    assert!(k_after > mul_div(k_before, 997, 1000), 5); // Fee is 0.3%, so k should not decrease more than that

    // Test Scenario 2: Swap token1 for token0
    let amount_in_1 = 2 * pow(10, 8);
    let token1_swap = primary_fungible_store::withdraw(bob, token1, amount_in_1);
    let empty_token_1 = primary_fungible_store::withdraw(bob, token0, 0);

    let (token0_out_1, token1_out_1) = amm_pair::swap(
        bob,
        pair,
        empty_token_1,
        1 * pow(10, 8),
        token1_swap,
        0,
        @bob
    );

    primary_fungible_store::deposit(@bob, token0_out_1);
    primary_fungible_store::deposit(@bob, token1_out_1);

    let (final_reserve0, final_reserve1, _) = amm_pair::get_reserves(pair);
    assert!(final_reserve1 == reserve1 + amount_in_1, 6);
    assert!(final_reserve0 < reserve0, 7); // Reserve0 should decrease after swapping for token0

    // Test balances
    let pool_balance0 = amm_pair::balance0(pair);
    let pool_balance1 = amm_pair::balance1(pair);
    assert!(pool_balance0 == final_reserve0, 8);
    assert!(pool_balance1 == final_reserve1, 9);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_mint_fee(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Enable protocol fee
    amm_controller::set_fee_to(deployer, @admin);

    // Add initial liquidity
    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Add more liquidity to trigger fee mint
    let token0_deposit2 = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit2 = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit2, token1_deposit2, @bob);

    // Verify fee was minted to fee recipient
    let fee_recipient_balance = amm_pair::lp_balance_of(@admin, pair);
    assert!(fee_recipient_balance > 0, 0);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_view_functions(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Test liquidity_pool_address_safe
    let (exists, _) = amm_pair::liquidity_pool_address_safe(token0, token1);
    assert!(exists, 0);

    // Test balance_of
    let balance = amm_pair::balance_of(pair, token0);
    assert!(balance == 0, 1);

    // Add liquidity and test other view functions
    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    let k_last = amm_pair::get_k_last(pair);
    assert!(k_last > 0, 2);

    let balance0 = amm_pair::balance0(pair);
    let balance1 = amm_pair::balance1(pair);
    assert!(balance0 == token0_amount, 3);
    assert!(balance1 == token1_amount, 4);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 5, location = razor_amm::amm_pair)] // ERROR_INSUFFICIENT_INPUT_AMOUNT
  fun test_swap_edge_cases(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Add initial liquidity
    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Test zero input amounts - this should fail with ERROR_INSUFFICIENT_INPUT_AMOUNT
    let empty_token0 = primary_fungible_store::withdraw(bob, token0, 0);
    let empty_token1 = primary_fungible_store::withdraw(bob, token1, 0);
    
    let (token0_out, token1_out) = amm_pair::swap(
        bob,
        pair,
        empty_token0,
        0,
        empty_token1,
        0,
        @bob
    );

    // These lines won't be reached due to expected failure
    primary_fungible_store::deposit(@bob, token0_out);
    primary_fungible_store::deposit(@bob, token1_out);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_swap_large_amounts(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Add initial liquidity
    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Test large amounts that would cause overflow
    let large_amount = 1000000 * pow(10, 8);
    test_coins::mint_razor(admin, signer::address_of(bob), large_amount);
    test_coins::mint_usdc(admin, signer::address_of(bob), large_amount);

    let token0_large = primary_fungible_store::withdraw(bob, token0, large_amount);
    let token1_large = primary_fungible_store::withdraw(bob, token1, 0);

    // Should handle large amounts correctly
    let (token0_out, token1_out) = amm_pair::swap(
        bob,
        pair,
        token0_large,
        0,
        token1_large,
        1 * pow(10, 8),
        @bob
    );

    primary_fungible_store::deposit(@bob, token0_out);
    primary_fungible_store::deposit(@bob, token1_out);

    // Verify the swap was successful
    let (reserve0_after, reserve1_after, _) = amm_pair::get_reserves(pair);
    assert!(reserve0_after > token0_amount, 0);
    assert!(reserve1_after < token1_amount, 1);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 22, location = razor_amm::amm_pair)] // ERROR_INSUFFICIENT_LIQUIDITY_MINT
  fun test_mint_zero_supply(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));

    // Try to mint with amounts that would result in zero liquidity
    let small_amount = MINIMUM_LIQUIDITY - 1;
    let token0_small = primary_fungible_store::withdraw(bob, token0, small_amount);
    let token1_small = primary_fungible_store::withdraw(bob, token1, small_amount);

    // This should fail with ERROR_INSUFFICIENT_LIQUIDITY_MINT
    amm_pair::mint(bob, token0_small, token1_small, @bob);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 65540, location = aptos_framework::fungible_asset)] // ERROR_INSUFFICIENT_LIQUIDITY_BURN
  fun test_burn_insufficient_liquidity(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Add initial liquidity
    let token0_amount = 1 * pow(10, 8);
    let token1_amount = 1 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Try to burn more than available
    let (token0_out, token1_out) = amm_pair::burn(bob, pair, 1000 * pow(10, 8));

    primary_fungible_store::deposit(@bob, token0_out);
    primary_fungible_store::deposit(@bob, token1_out);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_cumulative_prices(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    amm_controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);

    amm_factory::create_pair(bob, object::object_address(&token0), object::object_address(&token1));
    let pair = amm_pair::liquidity_pool(token0, token1);

    // Add initial liquidity
    let token0_amount = 5 * pow(10, 8);
    let token1_amount = 10 * pow(10, 8);

    let token0_deposit = primary_fungible_store::withdraw(bob, token0, token0_amount);
    let token1_deposit = primary_fungible_store::withdraw(bob, token1, token1_amount);
    amm_pair::mint(bob, token0_deposit, token1_deposit, @bob);

    // Get initial cumulative prices
    let (price0_initial, price1_initial) = amm_pair::get_cumulative_prices(pair);

    // Perform a swap to change prices
    let amount_in = 1 * pow(10, 8);
    let token0_swap = primary_fungible_store::withdraw(bob, token0, amount_in);
    let empty_token = primary_fungible_store::withdraw(bob, token1, 0);

    let (token0_out, token1_out) = amm_pair::swap(
        bob,
        pair,
        token0_swap,
        0,
        empty_token,
        1 * pow(10, 7),
        @bob
    );

    primary_fungible_store::deposit(@bob, token0_out);
    primary_fungible_store::deposit(@bob, token1_out);

    // Check that cumulative prices have updated
    let (price0_after, price1_after) = amm_pair::get_cumulative_prices(pair);
    assert!(price0_after >= price0_initial, 0);
    assert!(price1_after >= price1_initial, 1);

    // Test individual price getters
    let price0_last = amm_pair::price_0_cumulative_last(pair);
    let price1_last = amm_pair::price_1_cumulative_last(pair);
    assert!(price0_last == price0_after, 2);
    assert!(price1_last == price1_after, 3);
  }
}