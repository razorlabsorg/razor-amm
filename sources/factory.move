module razor_amm::factory {
  use std::vector;
  use std::signer;

  use aptos_std::smart_vector::{Self, SmartVector};
  use aptos_std::simple_map::{Self, SimpleMap};

  use aptos_framework::event;
  use aptos_framework::fungible_asset::Metadata;
  use aptos_framework::object::{Self, Object};

  use razor_amm::controller;
  use razor_amm::pair::{Self, Pair};
  use razor_amm::swap_library;

  /// Identical Addresses
  const ERROR_IDENTICAL_ADDRESSES: u64 = 1;
  /// The pair already exists
  const ERROR_PAIR_EXISTS: u64 = 2;

  struct Factory has key {
    all_pairs: SmartVector<address>,
    pair_map: SimpleMap<vector<u8>, address>,
  }

  #[event]
  struct PairCreatedEvent has drop, store {
    pair: address,
    creator: address,
    token0: address,
    token1: address,
  }

  fun init_module(deployer: &signer) {
    move_to(deployer, Factory {
      all_pairs: smart_vector::new(),
      pair_map: simple_map::new(),
    });
  }

  #[view]
  public fun is_initialized(): bool {
    exists<Factory>(@razor_amm)
  }

  public entry fun create_pair(
    sender: &signer,
    tokenA: address,
    tokenB: address,
  ) acquires Factory {
    let token0_object = object::address_to_object<Metadata>(tokenA);
    let token1_object = object::address_to_object<Metadata>(tokenB);
    assert!(tokenA != tokenB, ERROR_IDENTICAL_ADDRESSES);
    let (token0, token1) = swap_library::sort_tokens(token0_object, token1_object);
    assert!(pair_exists(token0, token1) == false, ERROR_PAIR_EXISTS);
    let pair = pair::initialize(token0, token1);
    let pair_address = object::object_address(&pair);
    let pair_seed = pair::get_pair_seed(token0, token1);
    smart_vector::push_back(&mut safe_factory_mut().all_pairs, pair_address);
    simple_map::add(&mut safe_factory_mut().pair_map, pair_seed, pair_address);

    let creator = signer::address_of(sender);

    event::emit(PairCreatedEvent {
      pair: pair_address,
      creator: creator,
      token0: object::object_address(&token0),
      token1: object::object_address(&token1),
    })
  }

  #[view]
  public fun all_pairs_length(): u64 acquires Factory {
    smart_vector::length(&safe_factory().all_pairs)
  }

  #[view]
  public fun all_pairs(): vector<address> acquires Factory {
    let all_pairs = &safe_factory().all_pairs;
    let results = vector[];
    let len = smart_vector::length(all_pairs);
    let i = 0;
    while (i < len) {
      vector::push_back(&mut results, *smart_vector::borrow(all_pairs, i));
      i = i + 1;
    };
    results
  }

  #[view]
  public fun all_pairs_paginated(start: u64, limit: u64): vector<address> acquires Factory {
    let factory = safe_factory();
    let all_pairs = &factory.all_pairs;
    let len = smart_vector::length(all_pairs);
    let end = if (start + limit > len) { len } else { start + limit };
        
    let results = vector::empty();
    let i = start;
    while (i < end) {
      vector::push_back(&mut results, *smart_vector::borrow(all_pairs, i));
      i = i + 1;
    };
    results
  }

  #[view]
  public fun get_pair(tokenA: address, tokenB: address): address acquires Factory {
    let token0_object = object::address_to_object<Metadata>(tokenA);
    let token1_object = object::address_to_object<Metadata>(tokenB);
    let (token0, token1) = swap_library::sort_tokens(token0_object, token1_object);
    let pair_seed = pair::get_pair_seed(token0, token1);
    let pair_map = &safe_factory().pair_map;
    if (simple_map::contains_key(pair_map, &pair_seed) == true) {
      return *simple_map::borrow(pair_map, &pair_seed)
    } else {
      return @0x0
    }
  }

  #[view]
  public fun pair_exists(tokenA: Object<Metadata>, tokenB: Object<Metadata>): bool acquires Factory {
    let (token0, token1) = swap_library::sort_tokens(tokenA, tokenB);
    let pair_seed = pair::get_pair_seed(token0, token1);
    let pair_map = &safe_factory().pair_map;
    let pair_exists = simple_map::contains_key(pair_map, &pair_seed);
    return pair_exists
  }

  #[view]
  public fun pair_exists_safe(tokenA: Object<Metadata>, tokenB: Object<Metadata>): bool {
    let (token0, token1) = swap_library::sort_tokens(tokenA, tokenB);
    let (is_exists, _) = pair::liquidity_pool_address_safe(token0, token1);
    is_exists
  }

  // This function is used to check if a pair exists by its address.
  // This is useful for checking if a pair exists without having to unpack the pair.
  // This function should not be used in the contract, as it does not check if the pair is initialized.
  // Therefore, it should only be used in the frontend.
  #[view]
  public fun pair_exists_for_frontend(pair: address): bool {
    let is_exists = object::object_exists<Pair>(pair);
    is_exists
  }

  public entry fun pause(account: &signer) {
    controller::pause(account);
  }

  public entry fun unpause(account: &signer) {
    controller::unpause(account);
  }

  public entry fun set_admin(account: &signer, admin: address) {
    controller::set_admin_address(account, admin);
  }

  public entry fun claim_admin(account: &signer) {
    controller::claim_admin(account);
  }

  inline fun safe_factory(): &Factory acquires Factory {
    borrow_global<Factory>(@razor_amm)
  }

  inline fun safe_factory_mut(): &mut Factory acquires Factory {
    borrow_global_mut<Factory>(@razor_amm)
  }

  #[test_only]
  public fun initialize_for_testing(deployer: &signer) {
    init_module(deployer);
  }
}