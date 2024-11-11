/*
 * Library for interacting with the oracle contract
 */
module razor_amm::oracle_library {
  use aptos_framework::object::Object;
  use aptos_framework::timestamp;

  use razor_amm::math;
  use razor_amm::pair::{Self, Pair};
  use razor_amm::uq64x64;

  // helper function that returns the current block timestamp
  #[view]
  public fun current_block_timestamp(): u64 {
    timestamp::now_seconds()
  }

  // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
  #[view]
  public fun current_cummulative_prices(pair: Object<Pair>): (u128, u128, u64) {
    let block_timestamp = current_block_timestamp();
    let (price0, price1) = pair::get_cummulative_prices(pair);

    let (reserve0, reserve1, block_timestamp_last) = pair::get_reserves(pair);
    if (block_timestamp_last != block_timestamp) {
      let time_elapsed = ((block_timestamp - block_timestamp_last) as u128);
      let price0_delta = uq64x64::to_u128(uq64x64::fraction(reserve1, reserve0)) * time_elapsed;
      let price1_delta = uq64x64::to_u128(uq64x64::fraction(reserve0, reserve1)) * time_elapsed;
      price0 = math::overflow_add(price0, price0_delta);
      price1 = math::overflow_add(price1, price1_delta);
    };

    (price0, price1, block_timestamp)
  }
}