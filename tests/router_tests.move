#[test_only]
module razor_amm::router_tests {
  use std::signer;
  use std::vector;

  use aptos_std::math64::pow;

  use aptos_framework::account;
  use aptos_framework::object;
  use aptos_framework::timestamp;

  use razor_amm::controller_tests;
  use razor_amm::test_coins;
  use razor_amm::router;
  use razor_amm::razor_token;
  use razor_amm::usdc_token;
  use razor_amm::usdt_token;
  use razor_amm::pair;
  use razor_amm::math;
  use razor_amm::swap_library;

  const MINIMUM_LIQUIDITY: u64 = 1000;
  const MAX_U64: u64 = 18446744073709551615;

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob, alice = @alice)]
  fun test_add_liquidity(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
    alice: &signer
  ) {
    account::create_account_for_test(signer::address_of(bob));
    account::create_account_for_test(signer::address_of(alice));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_razor(admin, signer::address_of(alice), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(alice), 100 * pow(10, 8));

    let bob_liquidity_x = 5 * pow(10, 8);
    let bob_liquidity_y = 10 * pow(10, 8);
    let alice_liquidity_x = 2 * pow(10, 8);
    let alice_liquidity_y = 4 * pow(10, 8);

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    router::add_liquidity(bob, token0_address, token1_address, bob_liquidity_x, bob_liquidity_y, 0, 0, @bob, 1000000000);
    router::add_liquidity(alice, token0_address, token1_address, alice_liquidity_x, alice_liquidity_y, 0, 0, @alice, 1000000000);

    let pair = pair::liquidity_pool(token0, token1);

    let (reserve_x, reserve_y, _) = pair::get_reserves(pair);

    let pool_lp_balance = pair::lp_balance_of(@razor_amm, pair);
    let bob_lp_balance = pair::lp_balance_of(@bob, pair);
    let alice_lp_balance = pair::lp_balance_of(@alice, pair);

    let deployer_supposed_lp_balance = MINIMUM_LIQUIDITY;
    let bob_supposed_lp_balance = math::sqrt_128(((bob_liquidity_x as u128) * (bob_liquidity_y as u128))) - MINIMUM_LIQUIDITY;
    let total_supply = bob_supposed_lp_balance + MINIMUM_LIQUIDITY;
    let alice_supposed_lp_balance = math::min((alice_liquidity_x) * total_supply / (bob_liquidity_x), (alice_liquidity_y) * total_supply / (bob_liquidity_y));

    assert!(reserve_x == bob_liquidity_x + alice_liquidity_x, 99);
    assert!(reserve_y == bob_liquidity_y + alice_liquidity_y, 98);
    
    assert!(bob_lp_balance == (bob_supposed_lp_balance as u64), 97);
    assert!(alice_lp_balance == (alice_supposed_lp_balance as u64), 96);
    assert!(pool_lp_balance == (deployer_supposed_lp_balance as u64), 95);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob, alice = @alice)]
  fun test_add_liquidity_with_less_x_ratio(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
    alice: &signer
  ) {
    account::create_account_for_test(signer::address_of(bob));
    account::create_account_for_test(signer::address_of(alice));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let razor_address = razor_token::razor_token_address();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    let bob_liquidity_x = 5 * pow(10, 8);
    let bob_liquidity_y = 10 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_liquidity_x, bob_liquidity_y, 0, 0, @bob, 1000000000);

    let bob_token_x_before_balance = if (token0_address == razor_address) razor_token::balance_of(@bob) else usdc_token::balance_of(@bob);
    let bob_token_y_before_balance = if (token0_address == razor_address) usdc_token::balance_of(@bob) else razor_token::balance_of(@bob);

    let bob_add_liquidity_x = 1 * pow(10, 8);
    let bob_add_liquidity_y = 5 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_add_liquidity_x, bob_add_liquidity_y, 0, 0, @bob, 1000000000);

    let bob_added_liquidity_x = bob_add_liquidity_x;
    let bob_added_liquidity_y = bob_add_liquidity_x * bob_liquidity_y / bob_liquidity_x;

    let pair = pair::liquidity_pool(token0, token1);

    let bob_token_x_after_balance = if (token0_address == razor_address) razor_token::balance_of(@bob) else usdc_token::balance_of(@bob);
    let bob_token_y_after_balance = if (token0_address == razor_address) usdc_token::balance_of(@bob) else razor_token::balance_of(@bob);
    let bob_lp_balance = pair::lp_balance_of(@bob, pair);
    let deployer_lp_balance = pair::lp_balance_of(@razor_amm, pair);

    let deployer_supposed_lp_balance = MINIMUM_LIQUIDITY;
    let bob_supposed_lp_balance = math::sqrt_128(((bob_liquidity_x as u128) * (bob_liquidity_y as u128))) - MINIMUM_LIQUIDITY;
    let total_supply = bob_supposed_lp_balance + MINIMUM_LIQUIDITY;
    bob_supposed_lp_balance = bob_supposed_lp_balance + math::min((bob_add_liquidity_x) * total_supply / (bob_liquidity_x), (bob_add_liquidity_y) * total_supply / (bob_liquidity_y));

    assert!((bob_token_x_before_balance - bob_token_x_after_balance) == bob_added_liquidity_x, 99);
    assert!((bob_token_y_before_balance - bob_token_y_after_balance) == bob_added_liquidity_y, 98);
    assert!(bob_lp_balance == (bob_supposed_lp_balance as u64), 97);
    assert!(deployer_lp_balance == (deployer_supposed_lp_balance as u64), 96);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob, alice = @alice)]
  fun test_add_liquidity_with_less_y_ratio(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
    alice: &signer
  ) {
    account::create_account_for_test(signer::address_of(bob));
    account::create_account_for_test(signer::address_of(alice));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let razor_address = razor_token::razor_token_address();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    let bob_liquidity_x = 5 * pow(10, 8);
    let bob_liquidity_y = 10 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_liquidity_x, bob_liquidity_y, 0, 0, @bob, 1000000000);

    let bob_token_x_before_balance = if (token0_address == razor_address) razor_token::balance_of(@bob) else usdc_token::balance_of(@bob);
    let bob_token_y_before_balance = if (token0_address == razor_address) usdc_token::balance_of(@bob) else razor_token::balance_of(@bob);

    let bob_add_liquidity_x = 5 * pow(10, 8);
    let bob_add_liquidity_y = 4 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_add_liquidity_x, bob_add_liquidity_y, 0, 0, @bob, 1000000000);

    let bob_added_liquidity_x = bob_add_liquidity_y * bob_liquidity_x / bob_liquidity_y;
    let bob_added_liquidity_y = bob_add_liquidity_y;

    let pair = pair::liquidity_pool(token0, token1);

    let bob_token_x_after_balance = if (token0_address == razor_address) razor_token::balance_of(@bob) else usdc_token::balance_of(@bob);
    let bob_token_y_after_balance = if (token0_address == razor_address) usdc_token::balance_of(@bob) else razor_token::balance_of(@bob);
    let bob_lp_balance = pair::lp_balance_of(@bob, pair);
    let deployer_lp_balance = pair::lp_balance_of(@razor_amm, pair);

    let deployer_supposed_lp_balance = MINIMUM_LIQUIDITY;
    let bob_supposed_lp_balance = math::sqrt_128(((bob_liquidity_x as u128) * (bob_liquidity_y as u128))) - MINIMUM_LIQUIDITY;
    let total_supply = bob_supposed_lp_balance + MINIMUM_LIQUIDITY;
    bob_supposed_lp_balance = bob_supposed_lp_balance + math::min((bob_add_liquidity_x) * total_supply / (bob_liquidity_x), (bob_add_liquidity_y) * total_supply / (bob_liquidity_y));

    assert!((bob_token_x_before_balance - bob_token_x_after_balance) == bob_added_liquidity_x, 99);
    assert!((bob_token_y_before_balance - bob_token_y_after_balance) == bob_added_liquidity_y, 98);
    assert!(bob_lp_balance == (bob_supposed_lp_balance as u64), 97);
    assert!(deployer_lp_balance == (deployer_supposed_lp_balance as u64), 96);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob, alice = @alice)]
  #[expected_failure(abort_code = 8, location = razor_amm::swap_library)]
  fun test_add_liquidity_with_less_x_ratio_and_less_than_y_min(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
    alice: &signer
  ) {
    account::create_account_for_test(signer::address_of(bob));
    account::create_account_for_test(signer::address_of(alice));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    let initial_reserve_x = 5 * pow(10, 8);
    let initial_reserve_y = 10 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, initial_reserve_x, initial_reserve_y, 0, 0, @bob, 1000000000);

    let bob_add_liquidity_x = 1 * pow(10, 8);
    let bob_add_liquidity_y = 5 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_add_liquidity_x, bob_add_liquidity_y, 0, 4 * pow(10, 8), @bob, 1000000000);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob, alice = @alice)]
  #[expected_failure(abort_code = 9, location = razor_amm::swap_library)]
  fun test_add_liquidity_with_less_y_ratio_and_less_than_x_min(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
    alice: &signer
  ) {
    account::create_account_for_test(signer::address_of(bob));
    account::create_account_for_test(signer::address_of(alice));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    let initial_reserve_x = 5 * pow(10, 8);
    let initial_reserve_y = 10 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, initial_reserve_x, initial_reserve_y, 0, 0, @bob, 1000000000);

    let bob_add_liquidity_x = 5 * pow(10, 8);
    let bob_add_liquidity_y = 4 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, bob_add_liquidity_x, bob_add_liquidity_y, 5 * pow(10, 8), 0, @bob, 1000000000);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_remove_liquidity(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));

    controller_tests::setup_test_with_genesis(deployer);

    test_coins::init_coins();
    test_coins::mint_razor(admin, signer::address_of(bob), 100000 * pow(10, 8));

    test_coins::mint_usdc(admin, signer::address_of(bob), 1000000 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let razor_address = razor_token::razor_token_address();
    
    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    let token0_amount = 1 * pow(10, 8);
    let token1_amount = 4 * pow(10, 8);

    let expected_liquidity = 2 * pow(10, 8);

    router::add_liquidity(bob, token0_address, token1_address, token0_amount, token1_amount, 0, 0, @bob, 1000000000);

    let pair = pair::liquidity_pool(token0, token1);

    router::remove_liquidity(bob, token0_address, token1_address, expected_liquidity - MINIMUM_LIQUIDITY, 0, 0, @bob, 1000000000);

    let bob_lp_balance = pair::lp_balance_of(@bob, pair);

    assert!(bob_lp_balance == 0, 0);

    let total_supply_token0 = if (token0_address == razor_address) razor_token::total_supply() else usdc_token::total_supply();
    let total_supply_token1 = if (token0_address == razor_address) usdc_token::total_supply() else razor_token::total_supply();
    let lp_total_supply = pair::lp_token_supply(pair);

    let bob_token0_balance = if (token0_address == razor_address) razor_token::balance_of(@bob) else usdc_token::balance_of(@bob);
    let bob_token1_balance = if (token0_address == razor_address) usdc_token::balance_of(@bob) else razor_token::balance_of(@bob);

    assert!(bob_token0_balance == ((total_supply_token0 as u64) - 500), 1);
    assert!(bob_token1_balance == ((total_supply_token1 as u64) - 2000), 2);

    assert!(lp_total_supply == (MINIMUM_LIQUIDITY as u128), 3);
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_swap_exact_tokens_for_tokens(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    // Mint initial tokens for bob
    test_coins::mint_razor(admin, signer::address_of(bob), 1000 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 1000 * pow(10, 8));

    let razor_metadata = razor_token::metadata();
    let usdc_metadata = usdc_token::metadata();
    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    let (token0, token1) = swap_library::sort_tokens(razor_metadata, usdc_metadata);
    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    // Add initial liquidity
    let initial_amount0 = 100 * pow(10, 8);
    let initial_amount1 = 100 * pow(10, 8);
    router::add_liquidity(
      bob, 
      token0_address, 
      token1_address, 
      initial_amount0, 
      initial_amount1, 
      0, 
      0, 
      @bob, 
      MAX_U64
    );

    // Record balances before swap
    let bob_razor_before = razor_token::balance_of(@bob);
    let bob_usdc_before = usdc_token::balance_of(@bob);

    // Create path vector for swap
    let path = vector::empty<address>();
    vector::push_back(&mut path, razor_address);
    vector::push_back(&mut path, usdc_address);

    // Perform swap
    let amount_in = 1 * pow(10, 8); // 1 RAZOR
    let min_amount_out = 1 * pow(10, 7); // Minimum 1 USDC expected
    router::swap_exact_tokens_for_tokens(
      bob,
      amount_in,
      min_amount_out,
      path,
      @bob,
      MAX_U64
    );

    // Verify balances changed correctly
    let bob_razor_after = razor_token::balance_of(@bob);
    let bob_usdc_after = usdc_token::balance_of(@bob);

    assert!(bob_razor_before - bob_razor_after == amount_in, 1); // Exact amount in was taken
    assert!(bob_usdc_after > bob_usdc_before, 2); // Received some USDC
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_swap_tokens_for_exact_tokens(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 1000 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 1000 * pow(10, 8));

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    // Add initial liquidity
    router::add_liquidity(
      bob, 
      razor_address,
      usdc_address,
      100 * pow(10, 8),
      100 * pow(10, 8),
      0,
      0,
      @bob,
      MAX_U64
    );

    let bob_razor_before = razor_token::balance_of(@bob);
    let bob_usdc_before = usdc_token::balance_of(@bob);

    // Create path
    let path = vector::empty<address>();
    vector::push_back(&mut path, razor_address);
    vector::push_back(&mut path, usdc_address);

    // Swap for exact output
    let amount_out = 1 * pow(10, 8); // Want exactly 1 USDC
    let max_amount_in = 2 * pow(10, 8); // Willing to spend up to 2 RAZOR
    router::swap_tokens_for_exact_tokens(
      bob,
      amount_out,
      max_amount_in,
      path,
      @bob,
      MAX_U64
    );

    let bob_razor_after = razor_token::balance_of(@bob);
    let bob_usdc_after = usdc_token::balance_of(@bob);

    assert!(bob_usdc_after - bob_usdc_before == amount_out, 1); // Got exact amount requested
    assert!(bob_razor_before - bob_razor_after <= max_amount_in, 2); // Didn't spend more than max
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 1, location = razor_amm::router)]
  fun test_swap_expired_deadline(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    // Add initial liquidity
    router::add_liquidity(
      bob,
      razor_address,
      usdc_address,
      50 * pow(10, 8),
      100 * pow(10, 8),
      0,
      0,
      @bob,
      MAX_U64
    );

    let path = vector::empty<address>();
    vector::push_back(&mut path, razor_address);
    vector::push_back(&mut path, usdc_address);

    // Set timestamp to future value
    timestamp::set_time_has_started_for_testing(admin);
    timestamp::update_global_time_for_test_secs(100);

    // Try to swap with expired deadline (0)
    router::swap_exact_tokens_for_tokens(
      bob,
      1 * pow(10, 8),
      0,
      path,
      @bob,
      0 // Expired deadline
    );
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  #[expected_failure(abort_code = 3, location = razor_amm::router)]
  fun test_swap_insufficient_output_amount(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();

    // Add initial liquidity
    router::add_liquidity(
      bob,
      razor_address,
      usdc_address,
      50 * pow(10, 8),
      100 * pow(10, 8),
      0,
      0,
      @bob,
      MAX_U64
    );

    let path = vector::empty<address>();
    vector::push_back(&mut path, razor_address);
    vector::push_back(&mut path, usdc_address);

    // Try to swap with unreasonably high minimum output
    router::swap_exact_tokens_for_tokens(
      bob,
      1 * pow(10, 8), // Input 1 RAZOR
      1000 * pow(10, 8), // Expect minimum 1000 USDC (impossible)
      path,
      @bob,
      MAX_U64
    );
  }

  #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
  fun test_multi_hop_swap(
    admin: &signer,
    deployer: &signer,
    bob: &signer,
  ) {
    account::create_account_for_test(signer::address_of(bob));
    controller_tests::setup_test_with_genesis(deployer);
    test_coins::init_coins();

    // Mint tokens for bob
    test_coins::mint_razor(admin, signer::address_of(bob), 200 * pow(10, 8));
    test_coins::mint_usdc(admin, signer::address_of(bob), 200 * pow(10, 8));
    test_coins::mint_usdt(admin, signer::address_of(bob), 200 * pow(10, 8));

    let razor_address = razor_token::razor_token_address();
    let usdc_address = usdc_token::usdc_token_address();
    let usdt_address = usdt_token::usdt_token_address();

    // Create RAZOR-USDC pool
    router::add_liquidity(
      bob,
      razor_address,
      usdc_address,
      50 * pow(10, 8),
      100 * pow(10, 8),
      0,
      0,
      @bob,
      MAX_U64
    );

    // Create USDC-USDT pool
    router::add_liquidity(
      bob,
      usdc_address,
      usdt_address,
      50 * pow(10, 8),
      50 * pow(10, 8),
      0,
      0,
      @bob,
      MAX_U64
    );

    let bob_razor_before = razor_token::balance_of(@bob);
    let bob_usdt_before = usdt_token::balance_of(@bob);

    // Create path for multi-hop swap: RAZOR -> USDC -> USDT
    let path = vector::empty<address>();
    vector::push_back(&mut path, razor_address);
    vector::push_back(&mut path, usdc_address);
    vector::push_back(&mut path, usdt_address);

    // Perform multi-hop swap
    router::swap_exact_tokens_for_tokens(
      bob,
      1 * pow(10, 8), // Input 1 RAZOR
      0, // Any output amount acceptable
      path,
      @bob,
      MAX_U64
    );

    let bob_razor_after = razor_token::balance_of(@bob);
    let bob_usdt_after = usdt_token::balance_of(@bob);

    assert!(bob_razor_before - bob_razor_after == 1 * pow(10, 8), 1); // Spent exactly 1 RAZOR
    assert!(bob_usdt_after > bob_usdt_before, 2); // Received some USDT
  }
}