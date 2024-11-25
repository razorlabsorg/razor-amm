
<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library"></a>

# Module `0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::swap_library`



-  [Constants](#@Constants_0)
-  [Function `is_sorted`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_is_sorted)
-  [Function `sort_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_sort_tokens)
-  [Function `pair_for`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_pair_for)
-  [Function `get_reserves`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_reserves)
-  [Function `quote`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_quote)
-  [Function `get_amount_out`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_out)
-  [Function `get_amount_in`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_in)
-  [Function `get_amounts_out`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_out)
-  [Function `get_amounts_in`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_in)
-  [Function `calc_optimal_coin_values`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_calc_optimal_coin_values)


<pre><code><b>use</b> <a href="">0x1::comparator</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::pair</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_MAX_U64"></a>



<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_MAX_U64">MAX_U64</a>: u64 = 18446744073709551615;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_IDENTICAL_ADDRESSES"></a>

Identical Addresses


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_IDENTICAL_ADDRESSES">ERROR_IDENTICAL_ADDRESSES</a>: u64 = 1;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>

Insufficient Input Amount


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 5;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>

Insufficient Output Amount


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 6;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_AMOUNT"></a>

Insufficient Amount


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>: u64 = 3;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_A_AMOUNT"></a>

Insufficient A Amount


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_A_AMOUNT">ERROR_INSUFFICIENT_A_AMOUNT</a>: u64 = 9;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_B_AMOUNT"></a>

Insufficient B Amount


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_B_AMOUNT">ERROR_INSUFFICIENT_B_AMOUNT</a>: u64 = 8;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_LIQUIDITY"></a>

Insufficient Liquidity


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>: u64 = 2;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INTERNAL_ERROR"></a>

Internal Error


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INTERNAL_ERROR">ERROR_INTERNAL_ERROR</a>: u64 = 10;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INVALID_PATH"></a>

Invalid Swap Path


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_INVALID_PATH">ERROR_INVALID_PATH</a>: u64 = 7;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_OVERFLOW"></a>

Overflow


<pre><code><b>const</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_ERROR_OVERFLOW">ERROR_OVERFLOW</a>: u64 = 4;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_is_sorted"></a>

## Function `is_sorted`

Determines if two token metadata objects are in canonical order based on their addresses
@param token0: First token metadata object
@param token1: Second token metadata object
@return bool: true if tokens are in correct order (token0 < token1)


<pre><code><b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_is_sorted">is_sorted</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_sort_tokens"></a>

## Function `sort_tokens`



<pre><code><b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_sort_tokens">sort_tokens</a>(token_a: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token_b: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): (<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_pair_for"></a>

## Function `pair_for`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_pair_for">pair_for</a>(token_a: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token_b: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair_Pair">pair::Pair</a>&gt;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_reserves"></a>

## Function `get_reserves`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_reserves">get_reserves</a>(token_a: <b>address</b>, token_b: <b>address</b>): (u64, u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_quote"></a>

## Function `quote`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_quote">quote</a>(amount_a: u64, reserve_a: u64, reserve_b: u64): u64
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_out"></a>

## Function `get_amount_out`



<pre><code><b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_out">get_amount_out</a>(amount_in: u64, reserve_in: u64, reserve_out: u64): u64
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_in"></a>

## Function `get_amount_in`



<pre><code><b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amount_in">get_amount_in</a>(amount_out: u64, reserve_in: u64, reserve_out: u64): u64
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_out"></a>

## Function `get_amounts_out`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_out">get_amounts_out</a>(amount_in: u64, path: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_in"></a>

## Function `get_amounts_in`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_get_amounts_in">get_amounts_in</a>(amount_out: u64, path: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_calc_optimal_coin_values"></a>

## Function `calc_optimal_coin_values`

Calculate optimal amounts of coins to add


<pre><code><b>public</b> <b>fun</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library_calc_optimal_coin_values">calc_optimal_coin_values</a>(token_a: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token_b: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, amount_a_desired: u64, amount_b_desired: u64, amount_aMin: u64, amount_bMin: u64): (u64, u64)
</code></pre>
