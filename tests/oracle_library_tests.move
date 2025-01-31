#[test_only]
module razor_amm::oracle_library_tests {
    use std::signer;

    use aptos_std::math64::pow;
    
    use aptos_framework::timestamp;
    use aptos_framework::account;
    use aptos_framework::object;

    use razor_amm::amm_controller_tests;
    use razor_amm::test_coins;
    use razor_amm::razor_token;
    use razor_amm::usdc_token;
    use razor_amm::oracle_library;
    use razor_amm::amm_pair;
    use razor_amm::amm_factory;
    use razor_amm::amm_router;
    
    use razor_libs::sort;
    
    // Test constants
    const INITIAL_A_COIN_AMOUNT: u64 = 1000000000;
    const INITIAL_B_COIN_AMOUNT: u64 = 1000000000;
    
    #[test(deployer = @razor_amm, bob = @bob)]
    fun test_current_block_timestamp(deployer: &signer, bob: &signer) {
      account::create_account_for_test(signer::address_of(bob));
      amm_controller_tests::setup_test_with_genesis(deployer);
      timestamp::update_global_time_for_test(10000000);
        
      let timestamp = oracle_library::current_block_timestamp();
      assert!(timestamp > 0, 0);
    }
    
    #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
    fun test_current_cumulative_prices_same_timestamp(
      admin: &signer, 
      deployer: &signer, 
      bob: &signer
    ) {
      account::create_account_for_test(signer::address_of(bob));
      amm_controller_tests::setup_test_with_genesis(deployer);

      test_coins::init_coins();

      test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
      test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

      let razor_metadata = razor_token::metadata();
      let usdc_metadata = usdc_token::metadata();

      let razor_address = razor_token::razor_token_address();
      let usdc_address = usdc_token::usdc_token_address();

      amm_factory::create_pair(bob, razor_address, usdc_address);

      let pair = amm_pair::liquidity_pool(razor_metadata, usdc_metadata);
        
      let (price0, price1, block_timestamp) = oracle_library::current_cumulative_prices(pair);
        
      // When timestamps are the same, cumulative prices should match the pair's stored prices
      let (stored_price0, stored_price1) = amm_pair::get_cumulative_prices(pair);
      assert!(price0 == stored_price0, 0);
      assert!(price1 == stored_price1, 1);
      assert!(block_timestamp == oracle_library::current_block_timestamp(), 2);
    }
    
    #[test(admin = @admin, deployer = @razor_amm, bob = @bob)]
    fun test_current_cumulative_prices_different_timestamp(
      admin: &signer, 
      deployer: &signer, 
      bob: &signer
    ) {
      account::create_account_for_test(signer::address_of(bob));
      amm_controller_tests::setup_test_with_genesis(deployer);

      test_coins::init_coins();

      test_coins::mint_razor(admin, signer::address_of(bob), 100 * pow(10, 8));
      test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

      let razor_metadata = razor_token::metadata();
      let usdc_metadata = usdc_token::metadata();

      let razor_address = razor_token::razor_token_address();
      let usdc_address = usdc_token::usdc_token_address();
        
      amm_factory::create_pair(bob, razor_address, usdc_address);

      let bob_liquidity_x = 5 * pow(10, 8);
      let bob_liquidity_y = 10 * pow(10, 8);

      let (token0, token1) = sort::sort_two_tokens(razor_metadata, usdc_metadata);
      let token0_address = object::object_address(&token0);
      let token1_address = object::object_address(&token1);

      amm_router::add_liquidity(bob, token0_address, token1_address, bob_liquidity_x, bob_liquidity_y, 0, 0, @bob, 1000000000);

      let pair = amm_pair::liquidity_pool(razor_metadata, usdc_metadata);
        
      let (initial_price0, initial_price1) = amm_pair::get_cumulative_prices(pair);
        
      timestamp::fast_forward_seconds(3600); // Advance by 1 hour
        
      let (price0, price1, block_timestamp) = oracle_library::current_cumulative_prices(pair);
        
      // Prices should be updated based on time elapsed
      assert!(price0 > initial_price0, 0);
      assert!(price1 > initial_price1, 1);
      assert!(block_timestamp == oracle_library::current_block_timestamp(), 2);
    }
}
