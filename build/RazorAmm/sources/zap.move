module razor_amm::zap {
  use std::option;
  use std::vector;
  use std::signer;

  use aptos_framework::aptos_coin::{AptosCoin};
  use aptos_framework::coin;
  use aptos_framework::event;
  use aptos_framework::object::{Self, Object};
  use aptos_framework::fungible_asset::{Metadata};
  use aptos_framework::timestamp;
  use aptos_framework::primary_fungible_store;

  use razor_libs::math;
  use razor_libs::utils;

  use razor_amm::controller;
  use razor_amm::pair::{Self, Pair};
  use razor_amm::router;

  
  const MINIMUM_AMOUNT: u64 = 1000;
  const WMOVE: address = @0xa;

  struct Zap has key {
    max_zap_reserve_ratio: u64,
  }

  #[event]
  struct NewMaxZapReserveRatioEvent has drop, store {
    max_zap_reserve_ratio: u64,
  }

  #[event]
  struct ZapInEvent has drop, store {
    token_to_zap: address,
    lp_token: address,
    token_amount_in: u64,
    lp_token_amount_received: u64,
    user: address,
  }

  #[event]
  struct ZapInRebalancingEvent has drop, store {
    token0_to_zap: address,
    token1_to_zap: address,
    lp_token: address,
    token0_amount_in: u64,
    token1_amount_in: u64,
    lp_token_amount_received: u64,
    user: address,
  }

  #[event]
  struct ZapOutEvent has drop, store {
    lp_token: address,
    token_to_receive: address,
    lp_token_amount: u64,
    token_amount_received: u64,
    user: address,
  }

  /// Zap amount too low
  const ERROR_AMOUNT_TOO_LOW: u64 = 1;
  /// Wrong Zap Token
  const ERROR_INVALID_TOKEN: u64 = 2;
  /// Insufficient reserves
  const ERROR_INSUFFICIENT_RESERVES: u64 = 3;
  /// Quantity higher than limit
  const ERROR_MAX_ZAP_RESERVE_RATIO: u64 = 4;
  /// Wrong trade direction
  const ERROR_WRONG_TRADE_DIRECTION: u64 = 5;
  /// Identical tokens
  const ERROR_SAME_TOKEN: u64 = 6;
  /// Insufficient liquidity to mint
  const ERROR_INSUFFICIENT_LIQUIDITY_MINT: u64 = 7;
  /// Not admin
  const ERROR_NOT_ADMIN: u64 = 8;

  fun init_module(deployer: &signer) {
    move_to(deployer, Zap {
      max_zap_reserve_ratio: 50
    });
  }

  #[view]
  public fun is_initialized(): bool {
    exists<Zap>(@razor_amm)
  }

  fun calculate_liquidity(
    lp_token: address,
    amount0: u64,
    amount1: u64,
  ): u64 {
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let total_supply = pair::lp_token_supply(lp_token_object);
    let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);
    let liquidity;
    if (total_supply == 0) {
      assert!(math::sqrt(amount0, amount1) > MINIMUM_AMOUNT, ERROR_INSUFFICIENT_LIQUIDITY_MINT);
      liquidity = math::sqrt(amount0, amount1) - MINIMUM_AMOUNT;
    } else {
      // normal tx should never overflow
      let t_amount0 = ((amount0 as u128) * total_supply / (reserve0 as u128) as u64);
      let t_amount1 = ((amount1 as u128) * total_supply / (reserve1 as u128) as u64);
      liquidity = math::min(t_amount0, t_amount1);
    };

    liquidity
  }

  // Calculate the swap amount to get the price at 50/50 split
  fun calculate_amount_to_swap(
    token0_amount_in: u64,
    reserve0: u64,
    reserve1: u64,
  ): u64 {
    let half_token0_amount = token0_amount_in / 2;
    let nominator = utils::get_amount_out(half_token0_amount, reserve0, reserve1);
    let denominator = utils::quote(
      half_token0_amount,
      reserve0 + half_token0_amount,
      reserve1 - nominator
    );

    // Adjustment for price impact
    let amount_to_swap = token0_amount_in - math::sqrt_128(
      ((half_token0_amount as u128) * (half_token0_amount as u128) * (nominator as u128)) / (denominator as u128)
    );

    amount_to_swap
  }

  // Calculate the swap amount to get the price at 50/50 split
  fun calculate_amount_to_swap_for_rebalancing(
    token0_amount_in: u64,
    token1_amount_in: u64,
    reserve0: u64,
    reserve1: u64,
    is_token0_sold: bool,
  ): u64 {
    let sell_token0 = if (token0_amount_in * reserve1 > token1_amount_in * reserve0) {
      true
    } else {
      false
    };

    let amount_to_swap;

    assert!(sell_token0 == is_token0_sold, ERROR_WRONG_TRADE_DIRECTION);

    if (sell_token0) {
      let token0_amount_to_sell = (token0_amount_in - (token1_amount_in * reserve0) / reserve1) / 2;
      let nominator = utils::get_amount_out(token0_amount_to_sell, reserve0, reserve1);
      let denominator = utils::quote(
        token0_amount_to_sell, 
        reserve0 + token0_amount_to_sell, 
        reserve1 - nominator
      );

      // Calculate the amount to sell (in token0)
      token0_amount_to_sell = (token0_amount_in - (token1_amount_in * (reserve0 + token0_amount_to_sell)) / (reserve1 - nominator)) / 2;
      // Adjustment for price impact
      amount_to_swap = 2 * token0_amount_to_sell - math::sqrt_128(((token0_amount_to_sell as u128) * (token0_amount_to_sell as u128) * (nominator as u128)) / (denominator as u128));
    } else {
      let token_1_amount_to_sell = (token1_amount_in - (token0_amount_in * reserve1) / reserve0) / 2;
      let nominator = utils::get_amount_out(token_1_amount_to_sell, reserve1, reserve0);

      let denominator = utils::quote(
        token_1_amount_to_sell,
        reserve1 + token_1_amount_to_sell,
        reserve0 - nominator
      );

      // Calculate the amount to sell (in token1)
      token_1_amount_to_sell = (token1_amount_in - ((token0_amount_in * (reserve1 + token_1_amount_to_sell)) / (reserve0 - nominator))) / 2;
      // Adjustment for price impact
      amount_to_swap = 2 * token_1_amount_to_sell - math::sqrt_128(((token_1_amount_to_sell as u128) * (token_1_amount_to_sell as u128) * (nominator as u128)) / (denominator as u128));
    };

    amount_to_swap
  }

  fun zap_in_internal(
    sender: &signer,
    token_to_zap: address,
    token_amount_in: u64,
    lp_token: address,
    token_amount_out_min: u64,
  ) acquires Zap {
    let zap = borrow_global<Zap>(@razor_amm);
    assert!(token_amount_in >= MINIMUM_AMOUNT, ERROR_AMOUNT_TOO_LOW);
    
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    
    let token0 = pair::token0(lp_token_object);
    let token1 = pair::token1(lp_token_object);

    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    assert!(token_to_zap == token0_address || token_to_zap == token1_address, ERROR_INVALID_TOKEN);

    let address_path = vector::empty<address>();
    let object_path = vector::empty<Object<Metadata>>();
    vector::push_back(&mut address_path, token_to_zap);
    vector::push_back(&mut object_path, object::address_to_object<Metadata>(token_to_zap));

    let swap_amount_in;
    {
      let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);
      assert!((reserve0 >= MINIMUM_AMOUNT) && (reserve1 >= MINIMUM_AMOUNT), ERROR_INSUFFICIENT_RESERVES);
      if (token_to_zap == token0_address) {
        swap_amount_in = calculate_amount_to_swap(token_amount_in, reserve0, reserve1);
        vector::push_back(&mut address_path, token1_address);
        vector::push_back(&mut object_path, token1);
        assert!(reserve0 / swap_amount_in >= zap.max_zap_reserve_ratio, ERROR_MAX_ZAP_RESERVE_RATIO);
      } else {
        swap_amount_in = calculate_amount_to_swap(token_amount_in, reserve1, reserve0);
        vector::push_back(&mut address_path, token0_address);
        vector::push_back(&mut object_path, token0);
        assert!(reserve1 / swap_amount_in >= zap.max_zap_reserve_ratio, ERROR_MAX_ZAP_RESERVE_RATIO);
      }
    };

    let swapped_amounts = router::get_amounts_out(swap_amount_in, object_path);

    router::swap_exact_tokens_for_tokens(
      sender, 
      swap_amount_in, 
      token_amount_out_min, 
      address_path, 
      signer::address_of(sender),
      timestamp::now_seconds() + 100
    );

    router::add_liquidity(
      sender,
      *vector::borrow(&address_path, 0),
      *vector::borrow(&address_path, 1),
      token_amount_in - *vector::borrow(&swapped_amounts, 0),
      *vector::borrow(&swapped_amounts, 1),
      1,
      1,
      signer::address_of(sender),
      timestamp::now_seconds() + 100
    );

    let liquidity_minted = calculate_liquidity(
      lp_token, 
      token_amount_in - *vector::borrow(&swapped_amounts, 0),
      *vector::borrow(&swapped_amounts, 1),
    );

    event::emit(ZapInEvent {
      token_to_zap,
      lp_token,
      token_amount_in,
      lp_token_amount_received: liquidity_minted,
      user: signer::address_of(sender),
    });
  }

  fun zap_in_rebalancing_internal(
    sender: &signer,
    token0_to_zap: address,
    token1_to_zap: address,
    token0_amount_in: u64,
    token1_amount_in: u64,
    lp_token: address,
    token_amount_in_max: u64,
    token_amount_out_min: u64,
    is_token0_sold: bool,
  ) acquires Zap {
    let zap = borrow_global<Zap>(@razor_amm);
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let token0_object = pair::token0(lp_token_object);
    let token1_object = pair::token1(lp_token_object);

    let token0 = object::object_address(&token0_object);
    let token1 = object::object_address(&token1_object);

    assert!(token0_to_zap == token0 || token0_to_zap == token1, ERROR_INVALID_TOKEN);
    assert!(token1_to_zap == token0 || token1_to_zap == token1, ERROR_INVALID_TOKEN);
    assert!(token0_to_zap != token1_to_zap, ERROR_SAME_TOKEN);

    let swap_amount_in;
    {
      let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);
      assert!((reserve0 >= MINIMUM_AMOUNT) && (reserve1 >= MINIMUM_AMOUNT), ERROR_INSUFFICIENT_RESERVES);
      if (token0_to_zap == token0) {
        swap_amount_in = calculate_amount_to_swap_for_rebalancing(token0_amount_in, token1_amount_in, reserve0, reserve1, is_token0_sold);
        assert!(reserve0 / swap_amount_in >= zap.max_zap_reserve_ratio, ERROR_MAX_ZAP_RESERVE_RATIO);
      } else {
        swap_amount_in = calculate_amount_to_swap_for_rebalancing(token0_amount_in, token1_amount_in, reserve1, reserve0, !is_token0_sold);
        assert!(reserve1 / swap_amount_in >= zap.max_zap_reserve_ratio, ERROR_MAX_ZAP_RESERVE_RATIO);
      }
    };

    assert!(swap_amount_in <= token_amount_in_max, ERROR_MAX_ZAP_RESERVE_RATIO);

    let address_path = vector::empty<address>();
    let object_path = vector::empty<Object<Metadata>>();
    if (is_token0_sold) {
      vector::push_back(&mut address_path, token0_to_zap);
      vector::push_back(&mut object_path, object::address_to_object<Metadata>(token0_to_zap));
      vector::push_back(&mut address_path, token1_to_zap);
      vector::push_back(&mut object_path, object::address_to_object<Metadata>(token1_to_zap));
    } else {
      vector::push_back(&mut address_path, token1_to_zap);
      vector::push_back(&mut object_path, object::address_to_object<Metadata>(token1_to_zap));
      vector::push_back(&mut address_path, token0_to_zap);
      vector::push_back(&mut object_path, object::address_to_object<Metadata>(token0_to_zap));
    };

    let swapped_amounts = router::get_amounts_out(swap_amount_in, object_path);

    router::swap_exact_tokens_for_tokens(
      sender,
      swap_amount_in,
      token_amount_out_min,
      address_path,
      signer::address_of(sender),
      timestamp::now_seconds() + 100
    );

    let amount0_in;
    let amount1_in;

    if (is_token0_sold) {
      amount0_in = (token0_amount_in - *vector::borrow(&swapped_amounts, 0));
      amount1_in = (token1_amount_in + *vector::borrow(&swapped_amounts, 1));

      router::add_liquidity(
        sender,
        *vector::borrow(&address_path, 0),
        *vector::borrow(&address_path, 1),
        amount0_in,
        amount1_in,
        1,
        1,
        signer::address_of(sender),
        timestamp::now_seconds() + 100
      )
    } else {
      amount0_in = (token1_amount_in - *vector::borrow(&swapped_amounts, 0));
      amount1_in = (token0_amount_in + *vector::borrow(&swapped_amounts, 1));

      router::add_liquidity(
        sender,
        *vector::borrow(&address_path, 0),
        *vector::borrow(&address_path, 1),
        amount0_in,
        amount1_in,
        1,
        1,
        signer::address_of(sender),
        timestamp::now_seconds() + 100
      )
    };

    let liquidity_minted = calculate_liquidity(
      lp_token, 
      amount0_in,
      amount1_in,
    );

    event::emit(ZapInRebalancingEvent {
      token0_to_zap,
      token1_to_zap,
      lp_token,
      token0_amount_in,
      token1_amount_in,
      lp_token_amount_received: liquidity_minted,
      user: signer::address_of(sender),
    });
  }

  fun zap_out_internal(
    sender: &signer,
    lp_token: address,
    liquidity: u64,
    token_to_receive: address,
    token_amount_out_min: u64,
  ) {
    let sender_address = signer::address_of(sender);
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let token0_object = pair::token0(lp_token_object);
    let token1_object = pair::token1(lp_token_object);

    let token0 = object::object_address(&token0_object);
    let token1 = object::object_address(&token1_object);

    assert!(token_to_receive == token0 || token_to_receive == token1, ERROR_INVALID_TOKEN);

    router::remove_liquidity(
      sender,
      token0,
      token1,
      liquidity,
      token_amount_out_min,
      token_amount_out_min,
      sender_address,
      timestamp::now_seconds() + 100
    );

    let path = vector::empty<address>();
    let swap_amount_in;

    if (token_to_receive == token0) {
      vector::push_back(&mut path, token1);
      vector::push_back(&mut path, token_to_receive);
      swap_amount_in = primary_fungible_store::balance(sender_address, token1_object);
    } else {
      vector::push_back(&mut path, token0);
      vector::push_back(&mut path, token_to_receive);
      swap_amount_in = primary_fungible_store::balance(sender_address, token0_object);
    };

    let receipt_token_object = object::address_to_object<Metadata>(token_to_receive);
    let balance_before = primary_fungible_store::balance(sender_address, receipt_token_object);

    // swap tokens
    router::swap_exact_tokens_for_tokens(
      sender,
      swap_amount_in,
      token_amount_out_min,
      path,
      sender_address,
      timestamp::now_seconds() + 100
    );

    let balance_after = primary_fungible_store::balance(sender_address, receipt_token_object);
    let token_amount_received = balance_after - balance_before;
    
    event::emit(ZapOutEvent {
      lp_token,
      token_to_receive,
      lp_token_amount: liquidity,
      token_amount_received,
      user: signer::address_of(sender),
    });
  }

  /*
  * @notice Zap MOVE in a MOVE pool (e.g. MOVE/token)
  * @param _lpToken: LP token address (e.g. RZR/MOVE)
  * @param _tokenAmountOutMin: minimum token amount (e.g. RZR) to receive in the intermediary swap (e.g. MOVE --> RZR)
  */
  public entry fun zap_in_move(
    sender: &signer,
    lp_token: address,
    amount_in: u64,
    token_amount_out_min: u64,
  ) acquires Zap {
    let sender_address = signer::address_of(sender);
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());
    let move_object_balance = primary_fungible_store::balance(sender_address, move_object);
    if (move_object_balance < amount_in) {
      let amount_move_to_deposit = amount_in - move_object_balance;
      router::wrap_move(sender, amount_move_to_deposit);
    };

    zap_in_internal(sender, WMOVE, amount_in, lp_token, token_amount_out_min);
  }

  /*
  * @notice Zap a token in (e.g. token/other token)
  * @param _tokenToZap: token to zap
  * @param _tokenAmountIn: amount of token to swap
  * @param _lpToken: LP token address (e.g. RZR/USDT)
  * @param _tokenAmountOutMin: minimum token to receive (e.g. RZR) in the intermediary swap (e.g. USDT --> RZR)
  */
  public entry fun zap_in_token(
    sender: &signer,
    token_to_zap: address,
    token_amount_in: u64,
    lp_token: address,
    token_amount_out_min: u64,
  ) acquires Zap {
    zap_in_internal(sender, token_to_zap, token_amount_in, lp_token, token_amount_out_min);
  }

  /*
  * @notice Zap two tokens in, rebalance them to 50-50, before adding them to LP
  * @param _token0ToZap: address of token0 to zap
  * @param _token1ToZap: address of token1 to zap
  * @param _token0AmountIn: amount of token0 to zap
  * @param _token1AmountIn: amount of token1 to zap
  * @param _lpToken: LP token address (token0/token1)
  * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
  * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
  * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
  */
  public entry fun zap_in_token_rebalancing(
    sender: &signer,
    token0_to_zap: address,
    token1_to_zap: address,
    token0_amount_in: u64,
    token1_amount_in: u64,
    lp_token: address,
    token_amount_in_max: u64,
    token_amount_out_min: u64,
    is_token0_sold: bool,
  ) acquires Zap {
    zap_in_rebalancing_internal(sender, token0_to_zap, token1_to_zap, token0_amount_in, token1_amount_in, lp_token, token_amount_in_max, token_amount_out_min, is_token0_sold);
  }

  public entry fun zap_in_move_rebalancing(
    sender: &signer,
    token1_to_zap: address,
    move_amount_in: u64,
    token1_amount_in: u64,
    lp_token: address,
    token_amount_in_max: u64,
    token_amount_out_min: u64,
    is_token0_sold: bool,
  ) acquires Zap {
    let sender_address = signer::address_of(sender);
    let move_object = option::destroy_some(coin::paired_metadata<AptosCoin>());
    let move_object_balance = primary_fungible_store::balance(sender_address, move_object);
    if (move_object_balance < move_amount_in) {
      let amount_move_to_deposit = move_amount_in - move_object_balance;
      router::wrap_move(sender, amount_move_to_deposit);
    };

    zap_in_rebalancing_internal(sender, WMOVE, token1_to_zap, move_amount_in, token1_amount_in, lp_token, token_amount_in_max, token_amount_out_min, is_token0_sold);
  }

  public entry fun zap_out_move(
    sender: &signer,
    lp_token: address,
    lp_token_amount: u64,
    token_amount_out_min: u64,
  ) {
    zap_out_internal(sender, lp_token, lp_token_amount, WMOVE, token_amount_out_min);
  }

  public entry fun zap_out_token(
    sender: &signer,
    lp_token: address,
    token_to_receive: address,
    lp_token_amount: u64,
    token_amount_out_min: u64,
  ) {
    zap_out_internal(sender, lp_token, lp_token_amount, token_to_receive, token_amount_out_min);
  }

  public entry fun update_max_zap_reserve_ratio(
    sender: &signer,
    max_zap_reserve_ratio: u64,
  ) acquires Zap {
    only_admin(sender);
    let zap = borrow_global_mut<Zap>(@razor_amm);
    zap.max_zap_reserve_ratio = max_zap_reserve_ratio;

    event::emit(NewMaxZapReserveRatioEvent {
      max_zap_reserve_ratio,
    });
  }

  #[view]
  public fun estimate_zap_in_swap(
    token_to_zap: address,
    token_amount_in: u64,
    lp_token: address
  ): (u64, u64, address) {
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let token0 = pair::token0(lp_token_object);
    let token1 = pair::token1(lp_token_object);

    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    assert!(token_to_zap == token0_address || token_to_zap == token1_address, ERROR_INVALID_TOKEN);

    let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);
    
    let swap_amount_in;
    let swap_amount_out;
    let swap_token_out;
    if (token_to_zap == token0_address) {
      swap_token_out = token1_address;
      swap_amount_in = calculate_amount_to_swap(token_amount_in, reserve0, reserve1);
      swap_amount_out = utils::get_amount_out(swap_amount_in, reserve0, reserve1);
    } else {
      swap_token_out = token0_address;
      swap_amount_in = calculate_amount_to_swap(token_amount_in, reserve1, reserve0);
      swap_amount_out = utils::get_amount_out(swap_amount_in, reserve1, reserve0);
    };

    (swap_amount_in, swap_amount_out, swap_token_out)
  }

  #[view]
  public fun estimate_zap_in_rebalancing_swap(
    token0_to_zap: address,
    token1_to_zap: address,
    token0_amount_in: u64,
    token1_amount_in: u64,
    lp_token: address,
  ): (u64, u64, bool) {
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let token0 = pair::token0(lp_token_object);
    let token1 = pair::token1(lp_token_object);

    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    assert!(token0_to_zap == token0_address || token0_to_zap == token1_address, ERROR_INVALID_TOKEN);
    assert!(token1_to_zap == token0_address || token1_to_zap == token1_address, ERROR_INVALID_TOKEN);
    assert!(token0_to_zap != token1_to_zap, ERROR_SAME_TOKEN);

    let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);

    let swap_amount_in;
    let swap_amount_out;
    let sell_token0;
    

    if (token0_to_zap == token0_address) {
      // Determine which token needs to be sold based on reserve ratios
      sell_token0 = if (token0_amount_in * reserve1 > token1_amount_in * reserve0) {
        true
      } else {
        false
      };
      // If token0_to_zap matches pair's token0
      swap_amount_in = calculate_amount_to_swap_for_rebalancing(
        token0_amount_in,
        token1_amount_in,
        reserve0,
        reserve1,
        sell_token0
      );

      swap_amount_out = if (sell_token0) {
        utils::get_amount_out(swap_amount_in, reserve0, reserve1)
      } else {
        utils::get_amount_out(swap_amount_in, reserve1, reserve0)
      };
    } else {
      // Determine which token needs to be sold based on reserve ratios
      sell_token0 = if (token0_amount_in * reserve0 > token1_amount_in * reserve1) {
        true
      } else {
        false
      };

      // If token0_to_zap matches pair's token1
      swap_amount_in = calculate_amount_to_swap_for_rebalancing(
        token0_amount_in,
        token1_amount_in,
        reserve1,
        reserve0,
        sell_token0
      );

      swap_amount_out = if (sell_token0) {
        utils::get_amount_out(swap_amount_in, reserve1, reserve0)
      } else {
        utils::get_amount_out(swap_amount_in, reserve0, reserve1)
      };
    };

    (swap_amount_in, swap_amount_out, sell_token0)
  }

  #[view]
  public fun estimate_zap_out_swap(
    lp_token: address,
    lp_token_amount: u64,
    token_to_receive: address,
  ): (u64, u64, address) {
    let lp_token_object = object::address_to_object<Pair>(lp_token);
    let token0 = pair::token0(lp_token_object);
    let token1 = pair::token1(lp_token_object);

    let token0_address = object::object_address(&token0);
    let token1_address = object::object_address(&token1);

    assert!(token_to_receive == token0_address || token_to_receive == token1_address, ERROR_INVALID_TOKEN);

    let (reserve0, reserve1, _) = pair::get_reserves(lp_token_object);
    let swap_amount_in;
    let swap_amount_out;
    let swap_token_out;

    if (token1_address == token_to_receive) {
      let token_amount_in = ((lp_token_amount * reserve0) as u128) / pair::lp_token_supply(lp_token_object);
      swap_amount_in = calculate_amount_to_swap((token_amount_in as u64), reserve0, reserve1);
      swap_amount_out = utils::get_amount_out(swap_amount_in, reserve0, reserve1);
      swap_token_out = token0_address
    } else {
      let token_amount_in = ((lp_token_amount * reserve1) as u128) / pair::lp_token_supply(lp_token_object);
      swap_amount_in = calculate_amount_to_swap((token_amount_in as u64), reserve1, reserve0);
      swap_amount_out = utils::get_amount_out(swap_amount_in, reserve1, reserve0);
      swap_token_out = token1_address
    };

    (swap_amount_in, swap_amount_out, swap_token_out)
  }

  inline fun only_admin(sender: &signer) {
    let admin = controller::get_admin();
    assert!(signer::address_of(sender) == admin, ERROR_NOT_ADMIN);
  }
}
