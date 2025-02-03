
<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle"></a>

# Module `0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::amm_oracle`



-  [Struct `Observation`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Observation)
-  [Struct `BlockInfo`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_BlockInfo)
-  [Resource `Oracle`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Oracle)
-  [Struct `UpdateEvent`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_UpdateEvent)
-  [Struct `RouterTokenEvent`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_RouterTokenEvent)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_initialize)
-  [Function `is_initialized`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_initialized)
-  [Function `update`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_update)
-  [Function `update_block_info`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_update_block_info)
-  [Function `get_quantity`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_quantity)
-  [Function `get_current_price`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_current_price)
-  [Function `get_lp_token_value`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_lp_token_value)
-  [Function `get_anchor_token`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_anchor_token)
-  [Function `get_average_block_time`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_average_block_time)
-  [Function `add_router_token`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_add_router_token)
-  [Function `remove_router_token`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_remove_router_token)
-  [Function `get_router_token_length`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_length)
-  [Function `is_router_token`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_router_token)
-  [Function `get_router_token`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token)
-  [Function `get_router_token_address`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_address)


<pre><code><b>use</b> <a href="">0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d::sort</a>;
<b>use</b> <a href="">0x1::block</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::math64</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::smart_vector</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="controller.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_controller">0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::amm_controller</a>;
<b>use</b> <a href="factory.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_factory">0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::amm_factory</a>;
<b>use</b> <a href="pair.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_pair">0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::amm_pair</a>;
<b>use</b> <a href="oracle_library.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library">0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::oracle_library</a>;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Observation"></a>

## Struct `Observation`



<pre><code><b>struct</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Observation">Observation</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_BlockInfo"></a>

## Struct `BlockInfo`



<pre><code><b>struct</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_BlockInfo">BlockInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Oracle"></a>

## Resource `Oracle`



<pre><code><b>struct</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_Oracle">Oracle</a> <b>has</b> key
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_UpdateEvent"></a>

## Struct `UpdateEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_UpdateEvent">UpdateEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_RouterTokenEvent"></a>

## Struct `RouterTokenEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_RouterTokenEvent">RouterTokenEvent</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_MAX_U64"></a>



<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_MAX_U64">MAX_U64</a>: u64 = 18446744073709551615;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_CYCLE"></a>



<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_CYCLE">CYCLE</a>: u64 = 1800;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_AMOUNT_OUT_OVERFLOW"></a>

Amount out overflow


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_AMOUNT_OUT_OVERFLOW">ERROR_AMOUNT_OUT_OVERFLOW</a>: u64 = 5;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_HEIGHT_DIFF_ZERO"></a>

Height difference is zero


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_HEIGHT_DIFF_ZERO">ERROR_HEIGHT_DIFF_ZERO</a>: u64 = 6;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_INDEX_OUT_OF_BOUNDS"></a>

Index out of bounds


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_INDEX_OUT_OF_BOUNDS">ERROR_INDEX_OUT_OF_BOUNDS</a>: u64 = 2;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_ONLY_ADMIN"></a>

Only admin can call this


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_ONLY_ADMIN">ERROR_ONLY_ADMIN</a>: u64 = 1;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_PRICE_CUMULATIVE_END_LESS_THAN_START"></a>

Price cumulative end is less than start


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_PRICE_CUMULATIVE_END_LESS_THAN_START">ERROR_PRICE_CUMULATIVE_END_LESS_THAN_START</a>: u64 = 4;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_TIME_ELAPSED_ZERO"></a>

Time elapsed is zero


<pre><code><b>const</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_ERROR_TIME_ELAPSED_ZERO">ERROR_TIME_ELAPSED_ZERO</a>: u64 = 3;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> entry <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_initialize">initialize</a>(anchor_token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_initialized"></a>

## Function `is_initialized`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_initialized">is_initialized</a>(): bool
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_update"></a>

## Function `update`



<pre><code><b>public</b> <b>fun</b> <b>update</b>(tokenA: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, tokenB: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_update_block_info"></a>

## Function `update_block_info`



<pre><code><b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_update_block_info">update_block_info</a>(): bool
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_quantity"></a>

## Function `get_quantity`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_quantity">get_quantity</a>(token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, amount: u64): u64
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_current_price"></a>

## Function `get_current_price`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_current_price">get_current_price</a>(token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): u128
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_lp_token_value"></a>

## Function `get_lp_token_value`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_lp_token_value">get_lp_token_value</a>(lp_token: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_pair_Pair">amm_pair::Pair</a>&gt;, amount: u64): u64
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_anchor_token"></a>

## Function `get_anchor_token`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_anchor_token">get_anchor_token</a>(): <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_average_block_time"></a>

## Function `get_average_block_time`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_average_block_time">get_average_block_time</a>(): u64
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_add_router_token"></a>

## Function `add_router_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_add_router_token">add_router_token</a>(sender: &<a href="">signer</a>, token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_remove_router_token"></a>

## Function `remove_router_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_remove_router_token">remove_router_token</a>(sender: &<a href="">signer</a>, token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_length"></a>

## Function `get_router_token_length`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_length">get_router_token_length</a>(): u64
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_router_token"></a>

## Function `is_router_token`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_is_router_token">is_router_token</a>(token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token"></a>

## Function `get_router_token`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token">get_router_token</a>(index: u64): <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_address"></a>

## Function `get_router_token_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_oracle_get_router_token_address">get_router_token_address</a>(index: u64): <b>address</b>
</code></pre>
