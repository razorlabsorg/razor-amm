
<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math"></a>

# Module `0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::liquidity_math`



-  [Constants](#@Constants_0)
-  [Function `compute_profit_maximizing_trade`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_profit_maximizing_trade)
-  [Function `get_reserves_after_arbitrage`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_reserves_after_arbitrage)
-  [Function `compute_liquidity_value`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_liquidity_value)
-  [Function `get_liquidity_value`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value)
-  [Function `get_liquidity_value_after_arbitrage_to_price`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value_after_arbitrage_to_price)


<pre><code><b>use</b> <a href="">0x1::error</a>;
<b>use</b> <a href="">0x1::math128</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="controller.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_controller">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::controller</a>;
<b>use</b> <a href="math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_math">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::math</a>;
<b>use</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::pair</a>;
<b>use</b> <a href="swap_library.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_swap_library">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::swap_library</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_ERROR_INSUFFICIENT_LIQUIDITY"></a>

Insufficient Liquidity


<pre><code><b>const</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>: u64 = 2;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_ERROR_ZERO_PAIR_RESERVES"></a>

Pair Reserves is Zero


<pre><code><b>const</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_ERROR_ZERO_PAIR_RESERVES">ERROR_ZERO_PAIR_RESERVES</a>: u64 = 1;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_profit_maximizing_trade"></a>

## Function `compute_profit_maximizing_trade`

Computes the optimal arbitrage trade to align pool price with true market price
Parameters:
* true_price_token_a - External market price of token_a in terms of some reference
* true_price_token_b - External market price of token_b in terms of same reference
* reserve_a - Current pool reserve of token_a
* reserve_b - Current pool reserve of token_b
Returns:
* (bool, u64) - Direction of trade (true = A->B) and optimal input amount


<pre><code><b>public</b> <b>fun</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_profit_maximizing_trade">compute_profit_maximizing_trade</a>(true_price_token_a: u64, true_price_token_b: u64, reserve_a: u64, reserve_b: u64): (bool, u64)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_reserves_after_arbitrage"></a>

## Function `get_reserves_after_arbitrage`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_reserves_after_arbitrage">get_reserves_after_arbitrage</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, true_price_token_a: u64, true_price_token_b: u64): (u64, u64)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_liquidity_value"></a>

## Function `compute_liquidity_value`



<pre><code><b>public</b> <b>fun</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_compute_liquidity_value">compute_liquidity_value</a>(reserves_a: u64, reserves_b: u64, total_supply: u128, liquidity_amount: u64, fee_on: bool, k_last: u128): (u128, u128)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value"></a>

## Function `get_liquidity_value`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value">get_liquidity_value</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, liquidity_amount: u64): (u128, u128)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value_after_arbitrage_to_price"></a>

## Function `get_liquidity_value_after_arbitrage_to_price`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="liquidity_math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_liquidity_math_get_liquidity_value_after_arbitrage_to_price">get_liquidity_value_after_arbitrage_to_price</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, true_price_token_a: u64, true_price_token_b: u64, liquidity_amount: u64): (u128, u128)
</code></pre>
