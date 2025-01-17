/// Router module for the Razor AMM DEX
/// Handles all swap operations and liquidity management
/// 
/// # Features
/// - Token swaps (exact input/output)
/// - Liquidity addition/removal
/// - Native MOVE token integration
/// - Legacy coin wrapping support
/// 
module razor_amm::router {
  use std::option;
  use std::signer;
  use std::vector;

  use aptos_framework::aptos_coin::AptosCoin;
  use aptos_framework::coin;
  use aptos_framework::object::{Self, Object};
  use aptos_framework::fungible_asset::{Self, FungibleAsset, Metadata};
  use aptos_framework::primary_fungible_store;
  use aptos_framework::timestamp;

  use razor_amm::factory;
  use razor_amm::pair;

  use razor_libs::utils;
  use razor_libs::sort;

  /// Transaction expired
  const ERROR_EXPIRED: u64 = 1;
  /// Insufficient Input Amount
  const ERROR_INSUFFICIENT_INPUT_AMOUNT: u64 = 2;
  /// Insufficient Output Amount
  const ERROR_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 3;
  /// Invalid Swap Path
  const ERROR_INVALID_PATH: u64 = 4;
  /// Insufficient Balance
  const ERROR_INSUFFICIENT_BALANCE: u64 = 5;
  /// Invalid Token Order
  const ERROR_INVALID_TOKEN_ORDER: u64 = 6;
  /// Invalid Amount (zero or overflow)
  const ERROR_INVALID_AMOUNT: u64 = 7;
  /// Invalid Path Length
  const ERROR_INVALID_PATH_LENGTH: u64 = 8;
  /// Identical Tokens
  const ERROR_IDENTICAL_TOKENS: u64 = 9;
  /// Insufficient Amount
  const ERROR_INSUFFICIENT_AMOUNT: u64 = 10;
  /// Insufficient A Amount
  const ERROR_INSUFFICIENT_A_AMOUNT: u64 = 11;
  /// Insufficient B Amount
  const ERROR_INSUFFICIENT_B_AMOUNT: u64 = 12;
  /// Internal Error
  const ERROR_INTERNAL_ERROR: u64 = 13;

  const WMOVE: address = @0xa;
  const MIN_PATH_LENGTH: u64 = 2;

  /// Calculate optimal amounts of coins to add
  fun calc_optimal_coin_values(
    token_a: Object<Metadata>,
    token_b: Object<Metadata>,
    amount_a_desired: u64,
    amount_b_desired: u64,
    amount_aMin: u64,
    amount_bMin: u64,
  ): (u64, u64) {
    // Add validation for minimum amounts
    assert!(amount_aMin <= amount_a_desired && amount_bMin <= amount_b_desired, ERROR_INSUFFICIENT_AMOUNT);
    
    let pair = pair::liquidity_pool(token_a, token_b);
    let (reserve_a, reserve_b, _) = pair::get_reserves(pair);

    if (!sort::is_sorted(token_a, token_b)) {
      (reserve_a, reserve_b) = (reserve_b, reserve_a)
    };

    if (reserve_a == 0 && reserve_b == 0) {
      (amount_a_desired, amount_b_desired)
    } else {
      let amount_b_optimal = utils::quote(amount_a_desired, reserve_a, reserve_b);
      if (amount_b_optimal <= amount_b_desired) {
        assert!(amount_b_optimal >= amount_bMin, ERROR_INSUFFICIENT_B_AMOUNT);
        (amount_a_desired, amount_b_optimal)
      } else {
        let amount_a_optimal = utils::quote(amount_b_desired, reserve_b, reserve_a);
        assert!(amount_a_optimal <= amount_a_desired, ERROR_INTERNAL_ERROR);
        assert!(amount_a_optimal >= amount_aMin, ERROR_INSUFFICIENT_A_AMOUNT);
        (amount_a_optimal, amount_b_desired)
      }
    }
  }

  /// Ensures the transaction deadline from frontend hasn't expired
  inline fun ensure(deadline: u64) {
    assert!(deadline >= timestamp::now_seconds(), ERROR_EXPIRED);
  }

  /// Validates that a path starts with an expected token address
  inline fun validate_path_start(path: &vector<address>, expected: address) {
    assert!(vector::length(path) >= MIN_PATH_LENGTH, ERROR_INVALID_PATH_LENGTH);
    assert!(*vector::borrow(path, 0) == expected, ERROR_INVALID_PATH);
  }

  /// Validates that a path ends with an expected token address
  inline fun validate_path_end(path: &vector<address>, expected: address) {
    let len = vector::length(path);
    assert!(len >= MIN_PATH_LENGTH, ERROR_INVALID_PATH_LENGTH);
    assert!(*vector::borrow(path, len - 1) == expected, ERROR_INVALID_PATH);
  }

  /// Validates the basic requirements for a swap path
  inline fun validate_swap_path(path: &vector<address>) {
    assert!(vector::length(path) >= MIN_PATH_LENGTH, ERROR_INVALID_PATH_LENGTH);
  }

  /// Ensures amount is non-zero
  inline fun validate_amount(amount: u64) {
    assert!(amount > 0, ERROR_INVALID_AMOUNT);
  }

  /// Ensures two tokens are not the same
  inline fun validate_token_pair(tokenA: address, tokenB: address) {
    assert!(tokenA != tokenB, ERROR_IDENTICAL_TOKENS);
  }

  /// Ensures sufficient balance exists or wraps more tokens
  inline fun ensure_sufficient_balance<CoinType>(
    sender: &signer,
    token: Object<Metadata>,
    required_amount: u64,
    is_move: bool
  ) {
    let sender_addr = signer::address_of(sender);
    let balance = primary_fungible_store::balance(sender_addr, token);
    if (balance < required_amount) {
      let amount_to_deposit = required_amount - balance;
      if (is_move) {
        wrap_move(sender, amount_to_deposit);
      } else {
        wrap_coin<CoinType>(sender, amount_to_deposit);
      };
    };
  }

  //===================== WRAP =======================================
  /*
    This function wraps a legacy coin value into a Fungible Asset. It is irreversible
    because the function for unwrapping in `0x1::coin` module is private. This is intentional
    to push the migration from the old coin standard to the new one. Technically there are no
    benefits to staying on the old standard, so it makes sense to keep it wrapped.
  */
  public entry fun wrap_coin<CoinType>(
    sender: &signer,
    amount: u64
  ) {
    let to = signer::address_of(sender);
    let coin = coin::withdraw<CoinType>(sender, amount);
    let fa = coin::coin_to_fungible_asset<CoinType>(coin);
    primary_fungible_store::deposit(to, fa);
  }

  public entry fun wrap_move(
    sender: &signer,
    amount: u64,
  ) {
    let to = signer::address_of(sender);
    let coin = coin::withdraw<AptosCoin>(sender, amount);
    let fa = coin::coin_to_fungible_asset<AptosCoin>(coin);
    primary_fungible_store::deposit(to, fa);
  }

  //===================== ADD LIQUIDITY =======================================

  inline fun add_liquidity_internal(
    sender: &signer,
    tokenA: Object<Metadata>,
    tokenB: Object<Metadata>,
    amountADesired: u64,
    amountBDesired: u64,
    amountAMin: u64,
    amountBMin: u64,
    to: address,
  ) {
    let tokenA_addr = object::object_address(&tokenA);
    let tokenB_addr = object::object_address(&tokenB);
    if (!factory::pair_exists(tokenA, tokenB)) {
      factory::create_pair(sender, tokenA_addr, tokenB_addr);
    };

    let (token0, token1) = sort::sort_two_tokens(tokenA, tokenB);
    let (amount0, amount1) = if (token0 == tokenA) {
        (amountADesired, amountBDesired)
    } else {
        (amountBDesired, amountADesired)
    };
    let (amount0Min, amount1Min) = if (token0 == tokenA) {
        (amountAMin, amountBMin)
    } else {
        (amountBMin, amountAMin)
    };

    let (amount0Optimal, amount1Optimal) = calc_optimal_coin_values(
      token0,
      token1,
      amount0,
      amount1,
      amount0Min,
      amount1Min
    );

    let asset0 = primary_fungible_store::withdraw(sender, token0, amount0Optimal);
    let asset1 = primary_fungible_store::withdraw(sender, token1, amount1Optimal);

    pair::mint(sender, asset0, asset1, to);
  }

  public entry fun add_liquidity(
    sender: &signer,
    tokenA: address,
    tokenB: address,
    amountADesired: u64,
    amountBDesired: u64,
    amountAMin: u64,
    amountBMin: u64,
    to: address,
    deadline: u64,
  ) {
    validate_token_pair(tokenA, tokenB);
    validate_amount(amountADesired);
    validate_amount(amountBDesired);
    ensure(deadline);

    let tokenA_object = object::address_to_object<Metadata>(tokenA);
    let tokenB_object = object::address_to_object<Metadata>(tokenB);
    add_liquidity_internal(
      sender,
      tokenA_object,
      tokenB_object, 
      amountADesired, 
      amountBDesired, 
      amountAMin, 
      amountBMin,
      to
    );
  }

  public entry fun add_liquidity_move(
    sender: &signer,
    token: address,
    amount_token_desired: u64,
    amount_token_min: u64,
    amount_move_desired: u64,
    amount_move_min: u64,
    to: address,
    deadline: u64,
  ) {
    validate_token_pair(token, WMOVE);
    validate_amount(amount_token_desired);
    validate_amount(amount_move_desired);
    ensure(deadline);
    
    let sender_addr = signer::address_of(sender);
    let token_object = object::address_to_object<Metadata>(token);
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());
    let move_addr = object::object_address(&move_object);

    let (token0, token1) = sort::sort_two_tokens(token_object, move_object);

    if (!factory::pair_exists(token0, token1)) {
      factory::create_pair(sender, token, move_addr);
    };

    // Calculate amounts based on token order
    let (amount0_desired, amount1_desired) = if (token0 == token_object) {
      (amount_token_desired, amount_move_desired)
    } else {
      (amount_move_desired, amount_token_desired)
    };
    
    let (amount0_min, amount1_min) = if (token0 == token_object) {
      (amount_token_min, amount_move_min)
    } else {
      (amount_move_min, amount_token_min)
    };

    let (amount0, amount1) = calc_optimal_coin_values(
      token0,
      token1,
      amount0_desired,
      amount1_desired,
      amount0_min,
      amount1_min,
    );

    let move_object_balance = primary_fungible_store::balance(sender_addr, move_object);
    if (move_object_balance < (if (token0 == move_object) { amount0 } else { amount1 })) {
      let amount_move_to_deposit = (if (token0 == move_object) { amount0 } else { amount1 }) - move_object_balance;
      wrap_move(sender, amount_move_to_deposit);
    };

    let (asset0, asset1) = if (token0 == token_object) {
      (
        primary_fungible_store::withdraw(sender, token_object, amount0),
        primary_fungible_store::withdraw(sender, move_object, amount1)
      )
    } else {
      (
        primary_fungible_store::withdraw(sender, move_object, amount0),
        primary_fungible_store::withdraw(sender, token_object, amount1)
      )
    };

    pair::mint(sender, asset0, asset1, to);
  }

  // We hope this will be deprecated soon
  public entry fun add_liquidity_coin<CoinType>(
    sender: &signer,
    token: address,
    amount_token_desired: u64,
    amount_token_min: u64,
    amount_coin_desired: u64,
    amount_coin_min: u64,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    let sender_addr = signer::address_of(sender);
    let token_object = object::address_to_object<Metadata>(token);
    let coin_object = option::destroy_some(coin::paired_metadata<CoinType>());
    let coin_addr = object::object_address(&coin_object);

    let (token0, token1) = sort::sort_two_tokens(token_object, coin_object);

    if (!factory::pair_exists(token0, token1)) {
        factory::create_pair(sender, token, coin_addr);
    };

    // Calculate amounts based on token order
    let (amount0_desired, amount1_desired) = if (token0 == token_object) {
      (amount_token_desired, amount_coin_desired)
    } else {
      (amount_coin_desired, amount_token_desired)
    };
    
    let (amount0_min, amount1_min) = if (token0 == token_object) {
      (amount_token_min, amount_coin_min)
    } else {
      (amount_coin_min, amount_token_min)
    };

    let (amount0, amount1) = calc_optimal_coin_values(
      token0,
      token1,
      amount0_desired,
      amount1_desired,
      amount0_min,
      amount1_min,
    );

    let coin_object_balance = primary_fungible_store::balance(sender_addr, coin_object);
    if (coin_object_balance < (if (token0 == coin_object) { amount0 } else { amount1 })) {
      let amount_coin_to_deposit = (if (token0 == coin_object) { amount0 } else { amount1 }) - coin_object_balance;
      wrap_coin<CoinType>(sender, amount_coin_to_deposit);
    };

    let (asset0, asset1) = if (token0 == token_object) {
      (
        primary_fungible_store::withdraw(sender, token_object, amount0),
        primary_fungible_store::withdraw(sender, coin_object, amount1)
      )
    } else {
      (
        primary_fungible_store::withdraw(sender, coin_object, amount0),
        primary_fungible_store::withdraw(sender, token_object, amount1)
      )
    };

    pair::mint(sender, asset0, asset1, to);
  }

  //===================== REMOVE LIQUIDITY =======================================

  inline fun remove_liquidity_internal(
    sender: &signer,
    tokenA: Object<Metadata>,
    tokenB: Object<Metadata>,
    liquidity: u64,
    amountAMin: u64,
    amountBMin: u64,
  ): (FungibleAsset, FungibleAsset) {
    let pair = pair::liquidity_pool(tokenA, tokenB);
    let (redeemedA, redeemedB) = pair::burn(sender, pair, liquidity);
    let amountA = fungible_asset::amount(&redeemedA);
    let amountB = fungible_asset::amount(&redeemedB);
    assert!(amountA >= amountAMin && amountB >= amountBMin, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
    (redeemedA, redeemedB)
  }

  public entry fun remove_liquidity(
    sender: &signer,
    tokenA: address,
    tokenB: address,
    liquidity: u64,
    amountAMin: u64,
    amountBMin: u64,
    to: address,
    deadline: u64
  ) {
    ensure(deadline);
    let tokenA_object = object::address_to_object<Metadata>(tokenA);
    let tokenB_object = object::address_to_object<Metadata>(tokenB);
    let (amountA, amountB) = remove_liquidity_internal(
      sender, 
      tokenA_object,
      tokenB_object, 
      liquidity, 
      amountAMin, 
      amountBMin
    );

    primary_fungible_store::deposit(to, amountA);
    primary_fungible_store::deposit(to, amountB);
  }

  public entry fun remove_liquidity_move(
    sender: &signer,
    token: address,
    liquidity: u64,
    amount_token_min: u64,
    amount_move_min: u64,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);

    let token_object = object::address_to_object<Metadata>(token);
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());

    let (amount_token, amount_move) = remove_liquidity_internal(
      sender, 
      token_object,
      move_object, 
      liquidity, 
      amount_token_min, 
      amount_move_min
    );

    primary_fungible_store::deposit(to, amount_token);
    primary_fungible_store::deposit(to, amount_move);
  }

  //===================== SWAP ==========================================
  public fun swap(
    sender: &signer,
    token_in: FungibleAsset,
    to_token: Object<Metadata>,
    to: address,
  ): FungibleAsset {
    // let account = signer::address_of(sender);
    let from_token = fungible_asset::asset_metadata(&token_in);
    let (token0, token1) = sort::sort_two_tokens(from_token, to_token);
    let pair = pair::liquidity_pool(token0, token1);

    let amount_in = fungible_asset::amount(&token_in);

    let (reserve0, reserve1, _) = pair::get_reserves(pair);
    // Use the correct reserves based on whether from_token is token0
    let (reserve_in, reserve_out) = if (from_token == token0) {
      (reserve0, reserve1)
    } else {
      (reserve1, reserve0)
    };

    let amount_out = utils::get_amount_out(amount_in, reserve_in, reserve_out);
    let (zero, coins_out);
    if (sort::is_sorted(from_token, to_token)) {
      (zero, coins_out) = pair::swap(sender, pair, token_in, 0, fungible_asset::zero(to_token), amount_out, to);
    } else {
      (coins_out, zero) = pair::swap(sender, pair, fungible_asset::zero(to_token), amount_out, token_in, 0, to);
    };
    
    fungible_asset::destroy_zero(zero);
    coins_out
  }

  public entry fun swap_exact_tokens_for_tokens(
    sender: &signer,
    amount_in: u64,
    amount_out_min: u64,
    path: vector<address>,
    to: address,
    deadline: u64
  ) {
    ensure(deadline);
    let length = vector::length(&path);
    let current_amount_in = amount_in;

    // First swap (token_in to first token)
    let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, 0));
    let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, 1));
    let in = primary_fungible_store::withdraw(sender, from_token, current_amount_in);
    let out = swap(sender, in, to_token, to);
    current_amount_in = fungible_asset::amount(&out);
    
    // If this is the only swap, check the output amount
    if (length == 2) {
      assert!(current_amount_in >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
    };

    primary_fungible_store::deposit(to, out);

    let i = 1;
    while (i < length - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let in = primary_fungible_store::withdraw(sender, from_token, current_amount_in);
      let out = swap(sender, in, to_token, to);

      // Only check final output amount against minimum
      if (i == length - 2) {
        assert!(fungible_asset::amount(&out) >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
      };

      // Update amount_in for next iteration using the output amount
      current_amount_in = fungible_asset::amount(&out);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    }
  }

  public entry fun swap_tokens_for_exact_tokens(
    sender: &signer,
    amount_out: u64,
    amount_in_max: u64,
    path: vector<address>,
    to: address,
    deadline: u64
  ) {
    ensure(deadline);
    let i = vector::length(&path) - 1;
    let current_amount_out = amount_out;
    let amounts = vector::empty<u64>();

    // First calculate all amounts backwards
    while (i > 0) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i - 1));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let (token0, token1) = sort::sort_two_tokens(from_token, to_token);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve_in, reserve_out, _) = pair::get_reserves(pair);
      let amount_in = utils::get_amount_in(current_amount_out, reserve_in, reserve_out);
      vector::push_back(&mut amounts, amount_in);
      current_amount_out = amount_in;
      i = i - 1;
    };

    // Verify the first amount is within limits
    let first_amount = *vector::borrow(&amounts, vector::length(&amounts) - 1);
    assert!(first_amount <= amount_in_max, ERROR_INSUFFICIENT_INPUT_AMOUNT);

    // Now execute the swaps forward
    i = 0;
    while (i < vector::length(&path) - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let amount_in = *vector::borrow(&amounts, vector::length(&amounts) - i - 1);
      let in = primary_fungible_store::withdraw(sender, from_token, amount_in);
      let out = swap(sender, in, to_token, to);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    };
  }

  public entry fun swap_exact_move_for_tokens(
    sender: &signer,
    amount_move: u64,
    amount_out_min: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    assert!(*vector::borrow(&path, 0) == WMOVE, ERROR_INVALID_PATH);

    let sender_addr = signer::address_of(sender);
    let length = vector::length(&path);
    let current_amount_in = amount_move;

    // Handle MOVE wrapping only for the first swap
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());
    let move_object_balance = primary_fungible_store::balance(sender_addr, move_object);
    if (move_object_balance < amount_move) {
      let amount_move_to_deposit = amount_move - move_object_balance;
      wrap_move(sender, amount_move_to_deposit);
    };

    // First swap (MOVE to first token)
    let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, 1));
    let in = primary_fungible_store::withdraw(sender, move_object, current_amount_in);
    let out = swap(sender, in, to_token, to);
    current_amount_in = fungible_asset::amount(&out);
    
    // If this is the only swap, check the output amount
    if (length == 2) {
      assert!(current_amount_in >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
    };

    primary_fungible_store::deposit(to, out);

    // Handle remaining swaps if any
    let i = 1;
    while (i < length - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let in = primary_fungible_store::withdraw(sender, from_token, current_amount_in);
      let out = swap(sender, in, to_token, to);
      
      // Only check final output amount against minimum
      if (i == length - 2) {
        assert!(fungible_asset::amount(&out) >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
      };
        
      current_amount_in = fungible_asset::amount(&out);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    }
  }

  public entry fun swap_tokens_for_exact_move(
    sender: &signer,
    amount_out: u64,
    amount_in_max: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    assert!(*vector::borrow(&path, vector::length(&path) - 1) == WMOVE, ERROR_INVALID_PATH);
    
    // Calculate amounts backwards first
    let i = vector::length(&path) - 1;
    let current_amount_out = amount_out;
    let amounts = vector::empty<u64>();

    while (i > 0) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i - 1));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let (token0, token1) = sort::sort_two_tokens(from_token, to_token);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve_in, reserve_out, _) = pair::get_reserves(pair);
      let amount_in = utils::get_amount_in(current_amount_out, reserve_in, reserve_out);
      vector::push_back(&mut amounts, amount_in);
      current_amount_out = amount_in;
      i = i - 1;
    };

    // Check if first amount is within limits
    let first_amount = *vector::borrow(&amounts, vector::length(&amounts) - 1);
    assert!(first_amount <= amount_in_max, ERROR_INSUFFICIENT_INPUT_AMOUNT);

    // Execute swaps forward
    i = 0;
    while (i < vector::length(&path) - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let amount_in = *vector::borrow(&amounts, vector::length(&amounts) - i - 1);
      let in = primary_fungible_store::withdraw(sender, from_token, amount_in);
      let out = swap(sender, in, to_token, to);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    };
  }

  public entry fun swap_exact_tokens_for_move(
    sender: &signer,
    amount_in: u64,
    amount_out_min: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    assert!(*vector::borrow(&path, vector::length(&path) - 1) == WMOVE, ERROR_INVALID_PATH);

    let i = 0;
    let length = vector::length(&path);
    let current_amount_in = amount_in;

    while (i < length - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let in = primary_fungible_store::withdraw(sender, from_token, current_amount_in);
      let out = swap(sender, in, to_token, to);
        
      // Only check final output amount against minimum
      if (i == length - 2) {
        assert!(fungible_asset::amount(&out) >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
      };
        
      // Update amount_in for next iteration using the output amount
      current_amount_in = fungible_asset::amount(&out);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    }
  }

  public entry fun swap_move_for_exact_tokens(
    sender: &signer,
    amount_move_max: u64,
    amount_out: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    assert!(*vector::borrow(&path, 0) == WMOVE, ERROR_INVALID_PATH);
    let sender_addr = signer::address_of(sender);

    // Calculate amounts backwards first
    let i = vector::length(&path) - 1;
    let current_amount_out = amount_out;
    let amounts = vector::empty<u64>();

    while (i > 0) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i - 1));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let (token0, token1) = sort::sort_two_tokens(from_token, to_token);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve_in, reserve_out, _) = pair::get_reserves(pair);
      let amount_in = utils::get_amount_in(current_amount_out, reserve_in, reserve_out);
      vector::push_back(&mut amounts, amount_in);
      current_amount_out = amount_in;
      i = i - 1;
    };

    // Check if first amount (MOVE amount) is within limits
    let move_amount = *vector::borrow(&amounts, vector::length(&amounts) - 1);
    assert!(move_amount <= amount_move_max, ERROR_INSUFFICIENT_INPUT_AMOUNT);

    // Handle MOVE wrapping only for the first swap
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());
    let move_object_balance = primary_fungible_store::balance(sender_addr, move_object);
    if (move_object_balance < move_amount) {
      let amount_move_to_deposit = move_amount - move_object_balance;
      wrap_move(sender, amount_move_to_deposit);
    };

    // Execute swaps forward
    i = 0;
    while (i < vector::length(&path) - 1) {
      let from_token = if (i == 0) {
        move_object
      } else {
        object::address_to_object<Metadata>(*vector::borrow(&path, i))
      };

      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let amount_in = *vector::borrow(&amounts, vector::length(&amounts) - i - 1);
      let in = primary_fungible_store::withdraw(sender, from_token, amount_in);
      let out = swap(sender, in, to_token, to);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    };
  }

  //===================== Legacy Coin Functions ==========================================
  /* 
   * These functions will probably be unused in the frontend and may be removed in the future.
   * We are keeping them for now for compatibility with tokens based on the legacy Coin standard.
   */
  public entry fun swap_exact_coin_for_tokens<CoinType>(
    sender: &signer,
    amount_coin: u64,
    amount_out_min: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);

    let coin_object = option::destroy_some(coin::paired_metadata<CoinType>());
    let coin_address = object::object_address(&coin_object);
    assert!(*vector::borrow(&path, 0) == coin_address, ERROR_INVALID_PATH);

    let sender_addr = signer::address_of(sender);
    let length = vector::length(&path);
    let current_amount_in = amount_coin;

    // Handle coin wrapping only for the first swap
    let coin_object_balance = primary_fungible_store::balance(sender_addr, coin_object);
    if (coin_object_balance < amount_coin) {
      let amount_coin_to_deposit = amount_coin - coin_object_balance;
      wrap_coin<CoinType>(sender, amount_coin_to_deposit);
    };

    // First swap (coin to first token)
    let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, 1));
    let in = primary_fungible_store::withdraw(sender, coin_object, current_amount_in);
    let out = swap(sender, in, to_token, to);
    current_amount_in = fungible_asset::amount(&out);
    primary_fungible_store::deposit(to, out);

    // Handle remaining swaps if any
    let i = 1;
    while (i < length - 1) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let in = primary_fungible_store::withdraw(sender, from_token, current_amount_in);
      let out = swap(sender, in, to_token, to);
      
      // Only check final output amount against minimum
      if (i == length - 2) {
        assert!(fungible_asset::amount(&out) >= amount_out_min, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
      };
        
      current_amount_in = fungible_asset::amount(&out);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    }
  }

  public entry fun swap_coin_for_exact_tokens<CoinType>(
    sender: &signer,
    amount_coin_max: u64,
    amount_out: u64,
    path: vector<address>,
    to: address,
    deadline: u64,
  ) {
    ensure(deadline);
    let coin_object = option::destroy_some(coin::paired_metadata<CoinType>());
    let coin_address = object::object_address(&coin_object);
    assert!(*vector::borrow(&path, 0) == coin_address, ERROR_INVALID_PATH);
    let sender_addr = signer::address_of(sender);

    // Calculate amounts backwards first
    let i = vector::length(&path) - 1;
    let current_amount_out = amount_out;
    let amounts = vector::empty<u64>();

    while (i > 0) {
      let from_token = object::address_to_object<Metadata>(*vector::borrow(&path, i - 1));
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i));
      let (token0, token1) = sort::sort_two_tokens(from_token, to_token);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve_in, reserve_out, _) = pair::get_reserves(pair);
      let amount_in = utils::get_amount_in(current_amount_out, reserve_in, reserve_out);
      vector::push_back(&mut amounts, amount_in);
      current_amount_out = amount_in;
      i = i - 1;
    };

    // Check if first amount (MOVE amount) is within limits
    let coin_amount = *vector::borrow(&amounts, vector::length(&amounts) - 1);
    assert!(coin_amount <= amount_coin_max, ERROR_INSUFFICIENT_INPUT_AMOUNT);

    // Handle coin wrapping only for the first swap
    let coin_object_balance = primary_fungible_store::balance(sender_addr, coin_object);
    if (coin_object_balance < coin_amount) {
      let amount_coin_to_deposit = coin_amount - coin_object_balance;
      wrap_coin<CoinType>(sender, amount_coin_to_deposit);
    };

    // Execute swaps forward
    i = 0;
    while (i < vector::length(&path) - 1) {
      let from_token = if (i == 0) {
        coin_object
      } else {
        object::address_to_object<Metadata>(*vector::borrow(&path, i))
      };
        
      let to_token = object::address_to_object<Metadata>(*vector::borrow(&path, i + 1));
      let amount_in = *vector::borrow(&amounts, vector::length(&amounts) - i - 1);
      let in = primary_fungible_store::withdraw(sender, from_token, amount_in);
      let out = swap(sender, in, to_token, to);
      primary_fungible_store::deposit(to, out);
      i = i + 1;
    };
  }

  // performs chained get_amount_out calculations on any number of pairs
  #[view]
  public fun get_amounts_out(
    amount_in: u64,
    path: vector<Object<Metadata>>,
  ): vector<u64> {
    assert!(vector::length(&path) >= 2, ERROR_INVALID_PATH);
    let amounts = vector::empty<u64>();
    let path_length = vector::length(&path);
    let i = 0;
    while (i < path_length) {
      vector::push_back(&mut amounts, 0);
      i = i + 1;
    };

    *vector::borrow_mut(&mut amounts, 0) = amount_in;

    let k = 0;
    while (k < path_length - 1) {
      let token_a = *vector::borrow(&path, k);
      let token_b = *vector::borrow(&path, k + 1);
      // We should sort the tokens to ensure correct reserve order
      let (token0, token1) = sort::sort_two_tokens(token_a, token_b);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve0, reserve1, _) = pair::get_reserves(pair);
      
      // Determine correct reserve order based on input token
      // Compare addresses instead of objects
      let token_a_addr = object::object_address(&token_a);
      let token0_addr = object::object_address(&token0);
      let (reserve_in, reserve_out) = if (token_a_addr == token0_addr) {
        (reserve0, reserve1)
      } else {
        (reserve1, reserve0)
      };
      let amount = *vector::borrow(&amounts, k);
      let amount_out = utils::get_amount_out(amount, reserve_in, reserve_out);
      *vector::borrow_mut(&mut amounts, k + 1) = amount_out;
      
      k = k + 1;
    };

    amounts
  }

  // performs chained get_amount_in calculations on any number of pairs
  #[view]
  public fun get_amounts_in(
    amount_out: u64,
    path: vector<Object<Metadata>>,
  ): vector<u64> {
    assert!(vector::length(&path) >= 2, ERROR_INVALID_PATH);
    let amounts = vector::empty<u64>();
    let path_length = vector::length(&path);
    let i = 0;
    while (i < path_length) {
      vector::push_back(&mut amounts, 0);
      i = i + 1;
    };

    *vector::borrow_mut(&mut amounts, path_length - 1) = amount_out;

    let k = path_length - 1;
    while (k > 0) {
      let token_a = *vector::borrow(&path, k - 1);
      let token_b = *vector::borrow(&path, k);
      // We should sort the tokens to ensure correct reserve order
      let (token0, token1) = sort::sort_two_tokens(token_a, token_b);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve0, reserve1, _) = pair::get_reserves(pair);
      
      // Determine correct reserve order based on input token
      // Compare addresses instead of objects
      let token_a_addr = object::object_address(&token_a);
      let token0_addr = object::object_address(&token0);
      let (reserve_in, reserve_out) = if (token_a_addr == token0_addr) {
        (reserve0, reserve1)
      } else {
        (reserve1, reserve0)
      };

      let amount = *vector::borrow(&amounts, k);
      let amount_in = utils::get_amount_in(amount, reserve_in, reserve_out);
      *vector::borrow_mut(&mut amounts, k - 1) = amount_in;
      
      k = k - 1;
    };

    amounts
  }
}
