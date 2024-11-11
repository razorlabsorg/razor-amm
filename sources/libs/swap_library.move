module razor_amm::swap_library {
  use std::vector;

  use aptos_framework::object::{Self, Object};
  use aptos_framework::fungible_asset::Metadata;

  use aptos_std::comparator;

  use razor_amm::pair::{Self, Pair};

  const MAX_U64: u64 = 18446744073709551615;
  
  /// Identical Addresses
  const ERROR_IDENTICAL_ADDRESSES: u64 = 1;
  /// Insufficient Liquidity
  const ERROR_INSUFFICIENT_LIQUIDITY: u64 = 2;
  /// Insufficient Amount
  const ERROR_INSUFFICIENT_AMOUNT: u64 = 3;
  /// Overflow
  const ERROR_OVERFLOW: u64 = 4;
  /// Insufficient Input Amount
  const ERROR_INSUFFICIENT_INPUT_AMOUNT: u64 = 5;
  /// Insufficient Output Amount
  const ERROR_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 6;
  /// Invalid Swap Path
  const ERROR_INVALID_PATH: u64 = 7;
  /// Insufficient B Amount
  const ERROR_INSUFFICIENT_B_AMOUNT: u64 = 8;
  /// Insufficient A Amount
  const ERROR_INSUFFICIENT_A_AMOUNT: u64 = 9;
  /// Internal Error
  const ERROR_INTERNAL_ERROR: u64 = 10;

  /// Determines if two token metadata objects are in canonical order based on their addresses
  /// @param token0: First token metadata object
  /// @param token1: Second token metadata object
  /// @return bool: true if tokens are in correct order (token0 < token1)
  public fun is_sorted(token0: Object<Metadata>, token1: Object<Metadata>): bool {
    let token0_addr = object::object_address(&token0);
    let token1_addr = object::object_address(&token1);
    comparator::is_smaller_than(&comparator::compare(&token0_addr, &token1_addr))
  }

  // returns sorted token Metadata objects, used to handle return values from 
  // pairs sorted in this order
  public fun sort_tokens(
    token_a: Object<Metadata>,
    token_b: Object<Metadata>,
  ): (Object<Metadata>, Object<Metadata>) {
    let token_a_addr = object::object_address(&token_a);
    let token_b_addr = object::object_address(&token_b);
    assert!(token_a_addr != token_b_addr, ERROR_IDENTICAL_ADDRESSES);
    let (token0, token1);
    if (is_sorted(token_a, token_b)) {
      (token0, token1) = (token_a, token_b)
    } else {
      (token0, token1) = (token_b, token_a)
    };

    (token0, token1)
  }

  // fetches the liquidity pool for token_a and token_b
  #[view]
  public fun pair_for(
    token_a: Object<Metadata>,
    token_b: Object<Metadata>,
  ): Object<Pair> {
    let (token0, token1) = sort_tokens(token_a, token_b);
    pair::liquidity_pool(token0, token1)
  }

  // fetches and sorts the reserves for a pair
  #[view]
  public fun get_reserves(
    token_a: address,
    token_b: address,
  ): (u64, u64) {
    let token_a_metadata = object::address_to_object<Metadata>(token_a);
    let token_b_metadata = object::address_to_object<Metadata>(token_b);
    // We should check if the tokens are valid before sorting
    assert!(token_a != token_b, ERROR_IDENTICAL_ADDRESSES);
    
    let (token0, token1) = sort_tokens(token_a_metadata, token_b_metadata);
    let pair = pair::liquidity_pool(token0, token1);
    let (reserve0, reserve1, _) = pair::get_reserves(pair);
    if (token_a_metadata == token0) {
      (reserve0, reserve1)
    } else {
      (reserve1, reserve0)
    }
  }

  // given some amount of an asset and pair reserves, 
  //returns an equivalent amount of the other asset
  #[view]
  public fun quote(
    amount_a: u64,
    reserve_a: u64,
    reserve_b: u64,
  ): u64 {
    assert!(amount_a > 0, ERROR_INSUFFICIENT_AMOUNT);
    assert!(reserve_a > 0 && reserve_b > 0, ERROR_INSUFFICIENT_LIQUIDITY);
    let amount_b = ((amount_a as u128) * (reserve_b as u128) / (reserve_a as u128) as u64);
    amount_b
  }

  // given an input amount of an asset and pair reserves, 
  // returns the maximum output amount of the other asset
  public fun get_amount_out(
    amount_in: u64,
    reserve_in: u64,
    reserve_out: u64,
  ): u64 {
    assert!(amount_in > 0, ERROR_INSUFFICIENT_INPUT_AMOUNT);
    assert!(reserve_in > 0 && reserve_out > 0, ERROR_INSUFFICIENT_LIQUIDITY);
    
    // Add check for maximum input to prevent overflow
    assert!(amount_in <= MAX_U64 / 997, ERROR_OVERFLOW); // Need to define MAX_U64
    
    let amount_in_with_fee = (amount_in as u128) * 997u128;
    let numerator = amount_in_with_fee * (reserve_out as u128);
    let denominator = (reserve_in as u128) * 1000 + amount_in_with_fee;
    let amount_out = numerator / denominator;
    (amount_out as u64)
  }

  // given an output amount of an asset and pair reserves, returns a required 
  // input amount of the other asset
  public fun get_amount_in(
    amount_out: u64,
    reserve_in: u64,
    reserve_out: u64,
  ): u64 {
    assert!(amount_out > 0, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
    assert!(reserve_in > 0 && reserve_out > 0, ERROR_INSUFFICIENT_LIQUIDITY);
    let numerator = (reserve_in as u128) * (amount_out as u128) * 1000;
    let denominator = ((reserve_out - amount_out) as u128) * ((997) as u128);
    let amount_in = numerator / denominator + 1;
    (amount_in as u64)
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
      let (token0, token1) = sort_tokens(token_a, token_b);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve0, reserve1, _) = pair::get_reserves(pair);
      
      // Determine correct reserve order based on input token
      let (reserve_in, reserve_out) = if (token_a == token0) {
        (reserve0, reserve1)
      } else {
        (reserve1, reserve0)
      };
      let amount = *vector::borrow(&amounts, k);
      let amount_out = get_amount_out(amount, reserve_in, reserve_out);
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
      let (token0, token1) = sort_tokens(token_a, token_b);
      let pair = pair::liquidity_pool(token0, token1);
      let (reserve0, reserve1, _) = pair::get_reserves(pair);
      
      // Determine correct reserve order based on input token
      let (reserve_in, reserve_out) = if (token_a == token0) {
        (reserve0, reserve1)
      } else {
        (reserve1, reserve0)
      };
      let amount = *vector::borrow(&amounts, k);
      let amount_in = get_amount_in(amount, reserve_in, reserve_out);
      *vector::borrow_mut(&mut amounts, k - 1) = amount_in;
      
      k = k - 1;
    };

    amounts
  }

  /// Calculate optimal amounts of coins to add
  public fun calc_optimal_coin_values(
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

    if (!is_sorted(token_a, token_b)) {
      (reserve_a, reserve_b) = (reserve_b, reserve_a)
    };

    if (reserve_a == 0 && reserve_b == 0) {
      (amount_a_desired, amount_b_desired)
    } else {
      let amount_b_optimal = quote(amount_a_desired, reserve_a, reserve_b);
      if (amount_b_optimal <= amount_b_desired) {
        assert!(amount_b_optimal >= amount_bMin, ERROR_INSUFFICIENT_B_AMOUNT);
        (amount_a_desired, amount_b_optimal)
      } else {
        let amount_a_optimal = quote(amount_b_desired, reserve_b, reserve_a);
        assert!(amount_a_optimal <= amount_a_desired, ERROR_INTERNAL_ERROR);
        assert!(amount_a_optimal >= amount_aMin, ERROR_INSUFFICIENT_A_AMOUNT);
        (amount_a_optimal, amount_b_desired)
      }
    }
  }
}
