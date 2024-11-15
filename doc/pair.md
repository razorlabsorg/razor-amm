
<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair"></a>

# Module `0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::pair`



-  [Struct `LPTokenRefs`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_LPTokenRefs)
-  [Resource `Pair`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair)
-  [Struct `MintEvent`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintEvent)
-  [Struct `MintFeeEvent`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintFeeEvent)
-  [Struct `BurnEvent`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_BurnEvent)
-  [Struct `SwapEvent`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SwapEvent)
-  [Struct `SyncEvent`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SyncEvent)
-  [Constants](#@Constants_0)
-  [Function `get_reserves`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_reserves)
-  [Function `get_k_last`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_k_last)
-  [Function `get_cummulative_prices`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_cummulative_prices)
-  [Function `price_0_cummulative_last`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_0_cummulative_last)
-  [Function `price_1_cummulative_last`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_1_cummulative_last)
-  [Function `balance0`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance0)
-  [Function `balance1`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance1)
-  [Function `balance_of`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance_of)
-  [Function `initialize`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_initialize)
-  [Function `unpack_pair`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_unpack_pair)
-  [Function `lp_token_supply`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_token_supply)
-  [Function `lp_balance_of`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_balance_of)
-  [Function `mint`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_mint)
-  [Function `burn`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_burn)
-  [Function `swap`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_swap)
-  [Function `liquidity_pool`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool)
-  [Function `liquidity_pool_address_safe`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address_safe)
-  [Function `liquidity_pool_address`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address)
-  [Function `pair_data`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_pair_data)
-  [Function `get_pair_seed`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_pair_seed)


<pre><code><b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::comparator</a>;
<b>use</b> <a href="">0x1::dispatchable_fungible_asset</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="controller.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_controller">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::controller</a>;
<b>use</b> <a href="math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_math">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::math</a>;
<b>use</b> <a href="uq64x64.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_uq64x64">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::uq64x64</a>;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_LPTokenRefs"></a>

## Struct `LPTokenRefs`



<pre><code><b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_LPTokenRefs">LPTokenRefs</a> <b>has</b> store
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair"></a>

## Resource `Pair`



<pre><code>#[resource_group_member(#[group = <a href="_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">Pair</a> <b>has</b> key
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintEvent"></a>

## Struct `MintEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintEvent">MintEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintFeeEvent"></a>

## Struct `MintFeeEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MintFeeEvent">MintFeeEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_BurnEvent"></a>

## Struct `BurnEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_BurnEvent">BurnEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SwapEvent"></a>

## Struct `SwapEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SwapEvent">SwapEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SyncEvent"></a>

## Struct `SyncEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_SyncEvent">SyncEvent</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_IDENTICAL_ADDRESSES"></a>

Identical Addresses


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_IDENTICAL_ADDRESSES">ERROR_IDENTICAL_ADDRESSES</a>: u64 = 2;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>

Insufficient Input Amount


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 5;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_LIQUIDITY_BURN"></a>

When not enough liquidity burned


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_LIQUIDITY_BURN">ERROR_INSUFFICIENT_LIQUIDITY_BURN</a>: u64 = 23;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_LIQUIDITY_MINT"></a>

When not enough liquidity minted


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_LIQUIDITY_MINT">ERROR_INSUFFICIENT_LIQUIDITY_MINT</a>: u64 = 22;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>

Insufficient Output Amount


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 6;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_K_ERROR"></a>

When contract K error


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_K_ERROR">ERROR_K_ERROR</a>: u64 = 24;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_LOCKED"></a>

When contract is not reentrant


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_LOCKED">ERROR_LOCKED</a>: u64 = 20;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_ZERO_AMOUNT"></a>

When zero amount for pool


<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_ERROR_ZERO_AMOUNT">ERROR_ZERO_AMOUNT</a>: u64 = 21;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_LP_TOKEN_DECIMALS"></a>



<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_LP_TOKEN_DECIMALS">LP_TOKEN_DECIMALS</a>: u8 = 8;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MINIMUM_LIQUIDITY"></a>



<pre><code><b>const</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>: u64 = 1000;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_reserves"></a>

## Function `get_reserves`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_reserves">get_reserves</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): (u64, u64, u64)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_k_last"></a>

## Function `get_k_last`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_k_last">get_k_last</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): u128
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_cummulative_prices"></a>

## Function `get_cummulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_cummulative_prices">get_cummulative_prices</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): (u128, u128)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_0_cummulative_last"></a>

## Function `price_0_cummulative_last`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_0_cummulative_last">price_0_cummulative_last</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): u128
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_1_cummulative_last"></a>

## Function `price_1_cummulative_last`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_price_1_cummulative_last">price_1_cummulative_last</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): u128
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance0"></a>

## Function `balance0`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance0">balance0</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): u64
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance1"></a>

## Function `balance1`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance1">balance1</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): u64
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance_of"></a>

## Function `balance_of`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_balance_of">balance_of</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): u64
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_initialize"></a>

## Function `initialize`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_initialize">initialize</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_unpack_pair"></a>

## Function `unpack_pair`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_unpack_pair">unpack_pair</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): (<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_token_supply"></a>

## Function `lp_token_supply`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_token_supply">lp_token_supply</a>&lt;T: key&gt;(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;T&gt;): u128
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_balance_of"></a>

## Function `lp_balance_of`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_lp_balance_of">lp_balance_of</a>&lt;T: key&gt;(<a href="">account</a>: <b>address</b>, <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;T&gt;): u64
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_mint"></a>

## Function `mint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_mint">mint</a>(sender: &<a href="">signer</a>, fungible_token0: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, fungible_token1: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, <b>to</b>: <b>address</b>)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_burn"></a>

## Function `burn`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_burn">burn</a>(sender: &<a href="">signer</a>, <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, amount: u64): (<a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_swap"></a>

## Function `swap`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_swap">swap</a>(sender: &<a href="">signer</a>, <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;, token0_in: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, amount0_out: u64, token1_in: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, amount1_out: u64, <b>to</b>: <b>address</b>): (<a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool"></a>

## Function `liquidity_pool`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool">liquidity_pool</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address_safe"></a>

## Function `liquidity_pool_address_safe`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address_safe">liquidity_pool_address_safe</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): (bool, <b>address</b>)
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address"></a>

## Function `liquidity_pool_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_liquidity_pool_address">liquidity_pool_address</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <b>address</b>
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_pair_data"></a>

## Function `pair_data`



<pre><code><b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_pair_data">pair_data</a>&lt;T: key&gt;(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: &<a href="_Object">object::Object</a>&lt;T&gt;): &<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_pair_seed"></a>

## Function `get_pair_seed`



<pre><code><b>public</b> <b>fun</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_get_pair_seed">get_pair_seed</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="">vector</a>&lt;u8&gt;
</code></pre>