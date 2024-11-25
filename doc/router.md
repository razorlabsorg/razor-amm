
<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router"></a>

# Module `0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::router`



-  [Constants](#@Constants_0)
-  [Function `wrap_coin`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_coin)
-  [Function `wrap_move`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_move)
-  [Function `add_liquidity`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity)
-  [Function `add_liquidity_move`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_move)
-  [Function `add_liquidity_coin`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_coin)
-  [Function `remove_liquidity`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity)
-  [Function `remove_liquidity_move`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity_move)
-  [Function `swap`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap)
-  [Function `swap_exact_tokens_for_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_tokens)
-  [Function `swap_tokens_for_exact_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_tokens)
-  [Function `swap_exact_move_for_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_move_for_tokens)
-  [Function `swap_tokens_for_exact_move`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_move)
-  [Function `swap_exact_tokens_for_move`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_move)
-  [Function `swap_move_for_exact_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_move_for_exact_tokens)
-  [Function `swap_exact_coin_for_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_coin_for_tokens)
-  [Function `swap_coin_for_exact_tokens`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_coin_for_exact_tokens)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="factory.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_factory">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::factory</a>;
<b>use</b> <a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::pair</a>;
<b>use</b> <a href="swap_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_swap_library">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::swap_library</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>

Insufficient Input Amount


<pre><code><b>const</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 2;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>

Insufficient Output Amount


<pre><code><b>const</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 3;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INVALID_PATH"></a>

Invalid Swap Path


<pre><code><b>const</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_INVALID_PATH">ERROR_INVALID_PATH</a>: u64 = 4;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_EXPIRED"></a>

Transaction expired


<pre><code><b>const</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_ERROR_EXPIRED">ERROR_EXPIRED</a>: u64 = 1;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_WMOVE"></a>



<pre><code><b>const</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_WMOVE">WMOVE</a>: <b>address</b> = 0xa;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_coin"></a>

## Function `wrap_coin`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_coin">wrap_coin</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_move"></a>

## Function `wrap_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_wrap_move">wrap_move</a>(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity"></a>

## Function `add_liquidity`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity">add_liquidity</a>(sender: &<a href="">signer</a>, tokenA: <b>address</b>, tokenB: <b>address</b>, amountADesired: u64, amountBDesired: u64, amountAMin: u64, amountBMin: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_move"></a>

## Function `add_liquidity_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_move">add_liquidity_move</a>(sender: &<a href="">signer</a>, token: <b>address</b>, amount_token_desired: u64, amount_token_min: u64, amount_move_desired: u64, amount_move_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_coin"></a>

## Function `add_liquidity_coin`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_add_liquidity_coin">add_liquidity_coin</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, token: <b>address</b>, amount_token_desired: u64, amount_token_min: u64, amount_coin_desired: u64, amount_coin_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity"></a>

## Function `remove_liquidity`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity">remove_liquidity</a>(sender: &<a href="">signer</a>, tokenA: <b>address</b>, tokenB: <b>address</b>, liquidity: u64, amountAMin: u64, amountBMin: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity_move"></a>

## Function `remove_liquidity_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_remove_liquidity_move">remove_liquidity_move</a>(sender: &<a href="">signer</a>, token: <b>address</b>, liquidity: u64, amount_token_min: u64, amount_move_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap"></a>

## Function `swap`



<pre><code><b>public</b> <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap">swap</a>(sender: &<a href="">signer</a>, token_in: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, to_token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, <b>to</b>: <b>address</b>): <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_tokens"></a>

## Function `swap_exact_tokens_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_tokens">swap_exact_tokens_for_tokens</a>(sender: &<a href="">signer</a>, amount_in: u64, amount_out_min: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_tokens"></a>

## Function `swap_tokens_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_tokens">swap_tokens_for_exact_tokens</a>(sender: &<a href="">signer</a>, amount_out: u64, amount_in_max: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_move_for_tokens"></a>

## Function `swap_exact_move_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_move_for_tokens">swap_exact_move_for_tokens</a>(sender: &<a href="">signer</a>, amount_move: u64, amount_out_min: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_move"></a>

## Function `swap_tokens_for_exact_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_tokens_for_exact_move">swap_tokens_for_exact_move</a>(sender: &<a href="">signer</a>, amount_out: u64, amount_in_max: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_move"></a>

## Function `swap_exact_tokens_for_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_tokens_for_move">swap_exact_tokens_for_move</a>(sender: &<a href="">signer</a>, amount_in: u64, amount_out_min: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_move_for_exact_tokens"></a>

## Function `swap_move_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_move_for_exact_tokens">swap_move_for_exact_tokens</a>(sender: &<a href="">signer</a>, amount_move_max: u64, amount_out: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_coin_for_tokens"></a>

## Function `swap_exact_coin_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_exact_coin_for_tokens">swap_exact_coin_for_tokens</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount_coin: u64, amount_out_min: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_coin_for_exact_tokens"></a>

## Function `swap_coin_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_router_swap_coin_for_exact_tokens">swap_coin_for_exact_tokens</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount_coin_max: u64, amount_out: u64, path: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>
