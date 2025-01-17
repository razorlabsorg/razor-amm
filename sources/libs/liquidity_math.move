/*
  Library containing some math for dealing with liquidity shares
  of a pair. For example computing their exact value in terms of
  the underlying tokens.
*/
module razor_amm::liquidity_math {
  use aptos_std::math64;
  use aptos_std::math128;

  use aptos_framework::object::Object;

  use razor_amm::controller;
  use razor_amm::pair::{Self, Pair};

  use razor_libs::math;
  use razor_libs::utils;

  /// Pair Reserves is Zero
  const ERROR_ZERO_PAIR_RESERVES: u64 = 1;
  /// Insufficient Liquidity
  const ERROR_INSUFFICIENT_LIQUIDITY: u64 = 2;

  /// Computes the optimal arbitrage trade to align pool price with true market price
  /// Parameters:
  /// * true_price_token_a - External market price of token_a in terms of some reference
  /// * true_price_token_b - External market price of token_b in terms of same reference
  /// * reserve_a - Current pool reserve of token_a
  /// * reserve_b - Current pool reserve of token_b
  /// Returns:
  /// * (bool, u64) - Direction of trade (true = A->B) and optimal input amount
  public fun compute_profit_maximizing_trade(
    true_price_token_a: u64,
    true_price_token_b: u64,
    reserve_a: u64,
    reserve_b: u64,
  ): (bool, u64) {
    // Check if we should trade A for B by comparing price ratios
    let a_to_b = math64::mul_div(reserve_a, true_price_token_b, reserve_b) < true_price_token_b;
    
    // Safe multiplication needed here to prevent overflow
    let reserve_invariant = math64::mul_div(reserve_a, reserve_b, 1);
    let true_price = if (a_to_b) true_price_token_a else true_price_token_b;
    let inverse_price = if (a_to_b) true_price_token_b else true_price_token_a;
    let inter = math64::mul_div((reserve_invariant * 1000), true_price, inverse_price * 997);
    let left_side = math::sqrt_128((inter as u128));

    let right = if (a_to_b) reserve_a * 1000 else reserve_b * 1000;

    let right_side = right / 997;

    if (left_side < right_side) return (false, 0);

    // compute the amount that must be sent to move the price to the profit-maximizing price
    let amount_in = left_side - right_side;

    (a_to_b, amount_in)
  }

  /* 
   * Gets the reserves after an arbitrage moves the price to the 
   * profit-maximizing ratio given an externally observed true price
  */
  #[view]
  public fun get_reserves_after_arbitrage(
    pair: Object<Pair>,
    true_price_token_a: u64,
    true_price_token_b: u64,
  ): (u64, u64) {
    // first get reserves before the swap
    let (reserve_a, reserve_b, _) = pair::get_reserves(pair);
    assert!(reserve_a > 0 && reserve_b > 0, ERROR_ZERO_PAIR_RESERVES);

    // then compute how much to swap to arb to the true price
    let (a_to_b, amount_in) = compute_profit_maximizing_trade(true_price_token_a, true_price_token_b, reserve_a, reserve_b);

    if (amount_in == 0) {
      return (reserve_a, reserve_b)
    };

    // now affect the trade to the reserves
    if (a_to_b) {
      let amount_out = utils::get_amount_out(amount_in, reserve_a, reserve_b);
      reserve_a = reserve_a + amount_in;
      reserve_b = reserve_b - amount_out;
    } else {
      let amount_out = utils::get_amount_out(amount_in, reserve_b, reserve_a);
      reserve_a = reserve_a - amount_out;
      reserve_b = reserve_b + amount_in;
    };

    return (reserve_a, reserve_b)
  }

  // computes liquidity value given all the parameters of the pair
  public fun compute_liquidity_value(
    reserves_a: u64,
    reserves_b: u64,
    total_supply: u128,
    liquidity_amount: u64,
    fee_on: bool,
    k_last: u128,
  ): (u128, u128) {
    let cast_liquidity_amount = (liquidity_amount as u128);
    let cast_reserves_a = (reserves_a as u128);
    let cast_reserves_b = (reserves_b as u128);
  
    if (fee_on && k_last > 0) {
      let root_k = math128::sqrt(cast_reserves_a * cast_reserves_b);
      let root_k_last = math128::sqrt(k_last);
      if (root_k > root_k_last) {
        let numerator1 = total_supply;
        let numerator2 = root_k - root_k_last;
        let denominator = root_k * 5 + root_k_last;
        let fee_liquidity = math128::mul_div(numerator1, numerator2, denominator);
        total_supply = total_supply + fee_liquidity;
      }
    };

    return (cast_reserves_a * cast_liquidity_amount / total_supply, cast_reserves_b * cast_liquidity_amount / total_supply)
  }

  /* Get all current parameters from the pair and compute value of a liquidity amount
  *  **note this is subject to manipulation, e.g sandwich attacks **. Prefer passing a
  *  manipulation resistant price to `get_liquidity_value_after_arbitrage_to_price`
  */
  #[view]
  public fun get_liquidity_value(
    pair: Object<Pair>,
    liquidity_amount: u64,
  ): (u128, u128) {
    let (reserve_a, reserve_b, _) = pair::get_reserves(pair);
    let fee_on = controller::get_fee_on();
    let k_last = if (fee_on) pair::get_k_last(pair) else 0;
    
    let total_supply = pair::lp_token_supply(pair);
    let (liquidity_valueA, liquidity_valueB) = compute_liquidity_value(
      reserve_a, 
      reserve_b, 
      total_supply, 
      liquidity_amount, 
      fee_on, 
      k_last
    );

    (liquidity_valueA, liquidity_valueB)
  }

  /* Given two tokens, token_a and token_b, and their "true price", i.e. the observed ratio
  *  of value of token_a to token_b, and a liquidity amount, returns the value of the liquidity
  *  in terms of token_a and token_b
  */
  #[view]
  public fun get_liquidity_value_after_arbitrage_to_price(
    pair: Object<Pair>,
    true_price_token_a: u64,
    true_price_token_b: u64,
    liquidity_amount: u64,
  ): (u128, u128) {
    let fee_on = controller::get_fee_on();
    let k_last = if (fee_on) pair::get_k_last(pair) else 0;
    let total_supply = pair::lp_token_supply(pair);

    // this also checks that totalSupply > 0
    assert!(total_supply >= (liquidity_amount as u128) && liquidity_amount > 0, ERROR_INSUFFICIENT_LIQUIDITY);
    let (reserve_a, reserve_b) = get_reserves_after_arbitrage(pair, true_price_token_a, true_price_token_b);

    let (liquidity_valueA, liquidity_valueB) = compute_liquidity_value(
      reserve_a,
      reserve_b, 
      total_supply, 
      liquidity_amount, 
      fee_on, 
      k_last
    );

    (liquidity_valueA, liquidity_valueB)
  }
}
