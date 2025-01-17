module razor_amm::amm_oracle {
  use std::signer;

  use aptos_framework::block;
  use aptos_framework::event;
  use aptos_framework::fungible_asset::{Self, Metadata};
  use aptos_framework::object::{Self, Object};
  use aptos_framework::timestamp;

  use aptos_std::math64;
  use aptos_std::simple_map::{Self, SimpleMap};
  use aptos_std::smart_vector::{Self, SmartVector};

  use razor_amm::amm_controller;
  use razor_amm::amm_factory;
  use razor_amm::oracle_library;
  use razor_amm::amm_pair::{Self, Pair};

  use razor_libs::sort;

  const MAX_U64: u64 = 18446744073709551615;

  /// Only admin can call this
  const ERROR_ONLY_ADMIN: u64 = 1;
  /// Index out of bounds
  const ERROR_INDEX_OUT_OF_BOUNDS: u64 = 2;
  /// Time elapsed is zero
  const ERROR_TIME_ELAPSED_ZERO: u64 = 3;
  /// Price cumulative end is less than start
  const ERROR_PRICE_CUMULATIVE_END_LESS_THAN_START: u64 = 4;
  /// Amount out overflow
  const ERROR_AMOUNT_OUT_OVERFLOW: u64 = 5;
  /// Height difference is zero
  const ERROR_HEIGHT_DIFF_ZERO: u64 = 6;

  struct Observation has copy, drop, store {
    timestamp: u64,
    price_0_cumulative: u128,
    price_1_cumulative: u128,
  }

  struct BlockInfo has copy, drop, store {
    height: u64,
    timestamp: u64,
  }

  struct Oracle has key {
    anchor_token: Object<Metadata>,
    block_info: BlockInfo,
    pair_observations: SimpleMap<Object<Pair>, Observation>,
    router_tokens: SmartVector<Object<Metadata>>,
  }

  #[event]
  struct UpdateEvent has drop, store {
    pair: address,
    price_0_cumulative: u128,
    price_1_cumulative: u128,
    timestamp: u64,
  }

  #[event]
  struct RouterTokenEvent has drop, store {
    token: address,
    is_added: bool,
  }

  const CYCLE: u64 = 1800; // 30 minutes

  public entry fun initialize(anchor_token: Object<Metadata>) {
    if (is_initialized()) {
      return
    };

    let swap_signer = &amm_controller::get_signer();
    move_to(swap_signer, Oracle {
      anchor_token: anchor_token,
      block_info: BlockInfo {
        height: block::get_current_block_height(),
        timestamp: timestamp::now_seconds(),
      },
      pair_observations: simple_map::new<Object<Pair>, Observation>(),
      router_tokens: smart_vector::new<Object<Metadata>>(),
    });
  }

  #[view]
  public fun is_initialized(): bool {
    exists<Oracle>(@razor_amm)
  }

  public fun update(tokenA: Object<Metadata>, tokenB: Object<Metadata>): bool acquires Oracle {
    let pair = amm_pair::liquidity_pool(tokenA, tokenB);
    if (!amm_factory::pair_exists(tokenA, tokenB)) {
      return false
    };

    let pair_observations = borrow_global_mut<Oracle>(@razor_amm).pair_observations;
    if (!simple_map::contains_key(&pair_observations, &pair)) {
        simple_map::add(&mut pair_observations, pair, Observation {
            timestamp: timestamp::now_seconds(),
            price_0_cumulative: 0,
            price_1_cumulative: 0,
        });
        return true
    };

    let observation = simple_map::borrow_mut(&mut pair_observations, &pair);
    let time_elapsed = timestamp::now_seconds() - observation.timestamp;
    if (time_elapsed < CYCLE) {
      return false
    };

    let (price_0_cumulative, price_1_cumulative, _) = oracle_library::current_cumulative_prices(pair);

    observation.price_0_cumulative = price_0_cumulative;
    observation.price_1_cumulative = price_1_cumulative;
    observation.timestamp = timestamp::now_seconds();

    true
  }

  public fun update_block_info(): bool acquires Oracle {
    let block_info = borrow_global_mut<Oracle>(@razor_amm).block_info;

    if ((block::get_current_block_height() - block_info.height) < 1000) {
      return false
    };

    block_info.height = block::get_current_block_height();
    block_info.timestamp = timestamp::now_seconds();
    true
  }

  fun compute_amount_out(
    price_cumulative_start: u128,
    price_cumulative_end: u128,
    time_elapsed: u64,
    amount_in: u64,
  ): u64 {
    assert!(time_elapsed > 0, ERROR_TIME_ELAPSED_ZERO);
    assert!(price_cumulative_end >= price_cumulative_start, ERROR_PRICE_CUMULATIVE_END_LESS_THAN_START);
    
    let price_average = (price_cumulative_end - price_cumulative_start) / (time_elapsed as u128);
    let amount_out = price_average * (amount_in as u128);

    assert!((amount_out as u64) <= MAX_U64, ERROR_AMOUNT_OUT_OVERFLOW);

    (amount_out as u64)
  }

  fun consult(
    token_in: Object<Metadata>,
    amount_in: u64,
    token_out: Object<Metadata>,
  ): u64  acquires Oracle {
    let pair = amm_pair::liquidity_pool(token_in, token_out);
    if (!amm_factory::pair_exists(token_in, token_out)) {
      return 0
    };

    let pair_observations = borrow_global<Oracle>(@razor_amm).pair_observations;
    let (price_0_cumulative, price_1_cumulative, _) = oracle_library::current_cumulative_prices(pair);

    let observation = simple_map::borrow(&pair_observations, &pair);
    let time_elapsed = timestamp::now_seconds() - observation.timestamp;
    
    let (token0, _) = sort::sort_two_tokens(token_in, token_out);

    if (token0 == token_in) {
      return compute_amount_out(observation.price_0_cumulative, price_0_cumulative, time_elapsed, amount_in)
    } else {
      return compute_amount_out(observation.price_1_cumulative, price_1_cumulative, time_elapsed, amount_in)
    }
  }

  #[view]
  public fun get_quantity(token: Object<Metadata>, amount: u64): u64 acquires Oracle {
    let decimal = fungible_asset::decimals(token);
    let anchor_token = borrow_global<Oracle>(@razor_amm).anchor_token;
    let quantity;
    if (token == anchor_token) {
      quantity = amount
    } else {
      quantity = (get_average_price(token) as u64) * amount / math64::pow(10, (decimal as u64))
    };

    (quantity as u64)
  }

  #[view]
  fun get_average_price(token: Object<Metadata>): u128 acquires Oracle {
    let decimal = fungible_asset::decimals(token);
    let amount = math64::pow(10, (decimal as u64));

    let price = 0;

    let anchor_token = borrow_global<Oracle>(@razor_amm).anchor_token;

    if (token == anchor_token) {
      price = amount
    } else if (amm_factory::pair_exists(token, anchor_token)) {
      price = consult(token, amount, anchor_token)
    } else {
      let length = get_router_token_length();
      let i = 0;
      while (i < length) {
        let intermediate = get_router_token(i);
        if (amm_factory::pair_exists(token, intermediate) && amm_factory::pair_exists(intermediate, anchor_token)) {
          let inter_price = consult(token, amount, intermediate);
          price = consult(intermediate, inter_price, anchor_token);
          break
        } else {
          price = 0;
        };

        i = i + 1
      }
    };

    (price as u128)
  }

  #[view]
  public fun get_current_price(token: Object<Metadata>): u128 acquires Oracle {
    let anchor_token = borrow_global<Oracle>(@razor_amm).anchor_token;
    let anchor_token_decimal = fungible_asset::decimals(anchor_token);
    let token_decimal = fungible_asset::decimals(token);

    let price: u128 = 0;

    if (token == anchor_token) {
      price = ((math64::pow(10, (anchor_token_decimal as u64))) as u128);
    } else if (amm_factory::pair_exists(token, anchor_token)) {
      let pair = amm_pair::liquidity_pool(token, anchor_token);
      let (reserve0, reserve1, _) = amm_pair::get_reserves(pair);
      price = ((math64::pow(10, (token_decimal as u64)) * reserve1 / reserve0) as u128);
    } else {
      let length = get_router_token_length();
      let i = 0;
      while (i < length) {
        let intermediate = get_router_token(i);
        if (amm_factory::pair_exists(token, intermediate) && amm_factory::pair_exists(intermediate, anchor_token)) {
          let pair1 = amm_pair::liquidity_pool(token, intermediate);
          let (reserve0, reserve1, _) = amm_pair::get_reserves(pair1);
          let amount_out = math64::pow(10, (token_decimal as u64)) * reserve1 / reserve0;
          let pair2 = amm_pair::liquidity_pool(intermediate, anchor_token);
          let (reserve2, reserve3, _) = amm_pair::get_reserves(pair2);
          price = ((amount_out * reserve3 / reserve2) as u128);
          break
        } else {
          price = 0;
        };

        i = i + 1
      }
    };

    (price as u128)
  }

  #[view]
  public fun get_lp_token_value(lp_token: Object<Pair>, amount: u64): u64 acquires Oracle {
    let total_supply = amm_pair::lp_token_supply(lp_token);

    let (token0, token1) = amm_pair::unpack_pair(lp_token);
    let token0_decimal = fungible_asset::decimals(token0);
    let token1_decimal = fungible_asset::decimals(token1);
    let (reserve0, reserve1, _) = amm_pair::get_reserves(lp_token);

    let token0_value = get_average_price(token0) * (reserve0 as u128) / ((math64::pow(10, (token0_decimal as u64))) as u128);
    let token1_value = get_average_price(token1) * (reserve1 as u128) / ((math64::pow(10, (token1_decimal as u64))) as u128);

    let value = token0_value + token1_value * (amount as u128) / total_supply;
    (value as u64) 
  }

  #[view]
  public fun get_anchor_token(): Object<Metadata> acquires Oracle {
    borrow_global<Oracle>(@razor_amm).anchor_token
  }

  #[view]
  public fun get_average_block_time(): u64 acquires Oracle {
    let block_info = borrow_global<Oracle>(@razor_amm).block_info;
    let height_diff = block::get_current_block_height() - block_info.height;
    assert!(height_diff > 0, ERROR_HEIGHT_DIFF_ZERO);
    let time_diff = timestamp::now_seconds() - block_info.timestamp;
    ((time_diff / height_diff) as u64)
  }

  public entry fun add_router_token(sender: &signer, token: Object<Metadata>) acquires Oracle {
    assert!(signer::address_of(sender) == amm_controller::get_admin(), ERROR_ONLY_ADMIN);
    let oracle = borrow_global_mut<Oracle>(@razor_amm);
    let tokens = &mut oracle.router_tokens;
    smart_vector::push_back(tokens, token);

    event::emit(RouterTokenEvent {
      token: object::object_address(&token),
      is_added: true,
    });
  }

  public entry fun remove_router_token(sender: &signer, token: Object<Metadata>) acquires Oracle {
    assert!(signer::address_of(sender) == amm_controller::get_admin(), ERROR_ONLY_ADMIN);
    let oracle = borrow_global_mut<Oracle>(@razor_amm);
    let tokens = &mut oracle.router_tokens;
    let (_, index) = smart_vector::index_of(tokens, &token);
    smart_vector::remove(tokens, index);

    event::emit(RouterTokenEvent {
      token: object::object_address(&token),
      is_added: false,
    });
  }

  #[view]
  public fun get_router_token_length(): u64 acquires Oracle {
    let tokens = &borrow_global<Oracle>(@razor_amm).router_tokens;

    smart_vector::length(tokens)
  }

  #[view]
  public fun is_router_token(token: Object<Metadata>): bool acquires Oracle {
    let tokens = &borrow_global<Oracle>(@razor_amm).router_tokens;
    let contains = smart_vector::contains(tokens, &token);
    contains
  }

  #[view]
  public fun get_router_token(index: u64): Object<Metadata> acquires Oracle {
    let tokens = &borrow_global<Oracle>(@razor_amm).router_tokens;
    let length = smart_vector::length(tokens);
    assert!(index <= length, ERROR_INDEX_OUT_OF_BOUNDS);
    *smart_vector::borrow(tokens, index)
  }

  #[view]
  public fun get_router_token_address(index: u64): address acquires Oracle {
    let tokens = &borrow_global<Oracle>(@razor_amm).router_tokens;
    let length = smart_vector::length(tokens);
    assert!(index <= length, ERROR_INDEX_OUT_OF_BOUNDS);
    let token = *smart_vector::borrow(tokens, index);
    return object::object_address(&token)
  }
}