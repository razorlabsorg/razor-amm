
<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router"></a>

# Module `0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a::amm_router`

Router module for the Razor AMM DEX
Handles all swap operations and liquidity management


<a id="@Features_0"></a>

## Features

- Token swaps (exact input/output)
- Liquidity addition/removal
- Native MOVE token integration
- Legacy coin wrapping support



-  [Features](#@Features_0)
-  [Constants](#@Constants_1)
-  [Function `wrap_coin`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_coin)
-  [Function `wrap_move`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_move)
-  [Function `add_liquidity`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity)
-  [Function `add_liquidity_move`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_move)
-  [Function `add_liquidity_coin`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_coin)
-  [Function `remove_liquidity`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity)
-  [Function `remove_liquidity_move`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity_move)
-  [Function `swap`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap)
-  [Function `swap_exact_tokens_for_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_tokens)
-  [Function `swap_tokens_for_exact_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_tokens)
-  [Function `swap_exact_move_for_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_move_for_tokens)
-  [Function `swap_tokens_for_exact_move`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_move)
-  [Function `swap_exact_tokens_for_move`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_move)
-  [Function `swap_move_for_exact_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_move_for_exact_tokens)
-  [Function `swap_exact_coin_for_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_coin_for_tokens)
-  [Function `swap_coin_for_exact_tokens`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_coin_for_exact_tokens)
-  [Function `get_amounts_out`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_out)
-  [Function `get_amounts_in`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_in)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="factory.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_factory">0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a::amm_factory</a>;
<b>use</b> <a href="pair.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_pair">0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a::amm_pair</a>;
<b>use</b> <a href="">0xccc5c4272c290d2315a6b34a06715f0b3d563cffae88f6a779140e774e3c35d6::sort</a>;
<b>use</b> <a href="">0xccc5c4272c290d2315a6b34a06715f0b3d563cffae88f6a779140e774e3c35d6::utils</a>;
</code></pre>



<a id="@Constants_1"></a>

## Constants


<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>

Insufficient Input Amount


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 2;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>

Insufficient Output Amount


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 3;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_AMOUNT"></a>

Insufficient Amount


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>: u64 = 10;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_EXPIRED"></a>

Transaction expired


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_EXPIRED">ERROR_EXPIRED</a>: u64 = 1;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_IDENTICAL_TOKENS"></a>

Identical Tokens


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_IDENTICAL_TOKENS">ERROR_IDENTICAL_TOKENS</a>: u64 = 9;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_A_AMOUNT"></a>

Insufficient A Amount


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_A_AMOUNT">ERROR_INSUFFICIENT_A_AMOUNT</a>: u64 = 11;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_BALANCE"></a>

Insufficient Balance


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_BALANCE">ERROR_INSUFFICIENT_BALANCE</a>: u64 = 5;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_B_AMOUNT"></a>

Insufficient B Amount


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INSUFFICIENT_B_AMOUNT">ERROR_INSUFFICIENT_B_AMOUNT</a>: u64 = 12;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INTERNAL_ERROR"></a>

Internal Error


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INTERNAL_ERROR">ERROR_INTERNAL_ERROR</a>: u64 = 13;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_AMOUNT"></a>

Invalid Amount (zero or overflow)


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>: u64 = 7;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_PATH"></a>

Invalid Swap Path


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_PATH">ERROR_INVALID_PATH</a>: u64 = 4;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_PATH_LENGTH"></a>

Invalid Path Length


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_PATH_LENGTH">ERROR_INVALID_PATH_LENGTH</a>: u64 = 8;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_TOKEN_ORDER"></a>

Invalid Token Order


<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_ERROR_INVALID_TOKEN_ORDER">ERROR_INVALID_TOKEN_ORDER</a>: u64 = 6;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_MIN_PATH_LENGTH"></a>



<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_MIN_PATH_LENGTH">MIN_PATH_LENGTH</a>: u64 = 2;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_WMOVE"></a>



<pre><code><b>const</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_WMOVE">WMOVE</a>: <b>address</b> = 0xa;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_coin"></a>

## Function `wrap_coin`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_coin">wrap_coin</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_move"></a>

## Function `wrap_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_wrap_move">wrap_move</a>(sender: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity"></a>

## Function `add_liquidity`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity">add_liquidity</a>(sender: &<a href="">signer</a>, tokenA: <b>address</b>, tokenB: <b>address</b>, amountADesired: u64, amountBDesired: u64, amountAMin: u64, amountBMin: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_move"></a>

## Function `add_liquidity_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_move">add_liquidity_move</a>(sender: &<a href="">signer</a>, token: <b>address</b>, amount_token_desired: u64, amount_token_min: u64, amount_move_desired: u64, amount_move_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_coin"></a>

## Function `add_liquidity_coin`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_add_liquidity_coin">add_liquidity_coin</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, token: <b>address</b>, amount_token_desired: u64, amount_token_min: u64, amount_coin_desired: u64, amount_coin_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity"></a>

## Function `remove_liquidity`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity">remove_liquidity</a>(sender: &<a href="">signer</a>, tokenA: <b>address</b>, tokenB: <b>address</b>, liquidity: u64, amountAMin: u64, amountBMin: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity_move"></a>

## Function `remove_liquidity_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_remove_liquidity_move">remove_liquidity_move</a>(sender: &<a href="">signer</a>, token: <b>address</b>, liquidity: u64, amount_token_min: u64, amount_move_min: u64, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap"></a>

## Function `swap`



<pre><code><b>public</b> <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap">swap</a>(sender: &<a href="">signer</a>, token_in: <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>, to_token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, <b>to</b>: <b>address</b>): <a href="_FungibleAsset">fungible_asset::FungibleAsset</a>
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_tokens"></a>

## Function `swap_exact_tokens_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_tokens">swap_exact_tokens_for_tokens</a>(sender: &<a href="">signer</a>, amount_in: u64, amount_out_min: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_tokens"></a>

## Function `swap_tokens_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_tokens">swap_tokens_for_exact_tokens</a>(sender: &<a href="">signer</a>, amount_out: u64, amount_in_max: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_move_for_tokens"></a>

## Function `swap_exact_move_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_move_for_tokens">swap_exact_move_for_tokens</a>(sender: &<a href="">signer</a>, amount_move: u64, amount_out_min: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_move"></a>

## Function `swap_tokens_for_exact_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_tokens_for_exact_move">swap_tokens_for_exact_move</a>(sender: &<a href="">signer</a>, amount_out: u64, amount_in_max: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_move"></a>

## Function `swap_exact_tokens_for_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_tokens_for_move">swap_exact_tokens_for_move</a>(sender: &<a href="">signer</a>, amount_in: u64, amount_out_min: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_move_for_exact_tokens"></a>

## Function `swap_move_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_move_for_exact_tokens">swap_move_for_exact_tokens</a>(sender: &<a href="">signer</a>, amount_move_max: u64, amount_out: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_coin_for_tokens"></a>

## Function `swap_exact_coin_for_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_exact_coin_for_tokens">swap_exact_coin_for_tokens</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount_coin: u64, amount_out_min: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_coin_for_exact_tokens"></a>

## Function `swap_coin_for_exact_tokens`



<pre><code><b>public</b> entry <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_swap_coin_for_exact_tokens">swap_coin_for_exact_tokens</a>&lt;CoinType&gt;(sender: &<a href="">signer</a>, amount_coin_max: u64, amount_out: u64, <a href="">path</a>: <a href="">vector</a>&lt;<b>address</b>&gt;, <b>to</b>: <b>address</b>, deadline: u64)
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_out"></a>

## Function `get_amounts_out`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_out">get_amounts_out</a>(amount_in: u64, <a href="">path</a>: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_in"></a>

## Function `get_amounts_in`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="router.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_router_get_amounts_in">get_amounts_in</a>(amount_out: u64, <a href="">path</a>: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;&gt;): <a href="">vector</a>&lt;u64&gt;
</code></pre>
