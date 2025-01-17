
<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap"></a>

# Module `0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::zap`



-  [Resource `Zap`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_Zap)
-  [Struct `NewMaxZapReserveRatioEvent`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_NewMaxZapReserveRatioEvent)
-  [Struct `ZapInEvent`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInEvent)
-  [Struct `ZapInRebalancingEvent`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInRebalancingEvent)
-  [Struct `ZapOutEvent`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapOutEvent)
-  [Constants](#@Constants_0)
-  [Function `is_initialized`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_is_initialized)
-  [Function `zap_in_move`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move)
-  [Function `zap_in_token`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token)
-  [Function `zap_in_token_rebalancing`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token_rebalancing)
-  [Function `zap_in_move_rebalancing`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move_rebalancing)
-  [Function `zap_out_move`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_move)
-  [Function `zap_out_token`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_token)
-  [Function `update_max_zap_reserve_ratio`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_update_max_zap_reserve_ratio)
-  [Function `estimate_zap_in_swap`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_swap)
-  [Function `estimate_zap_in_rebalancing_swap`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_rebalancing_swap)
-  [Function `estimate_zap_out_swap`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_out_swap)


<pre><code><b>use</b> <a href="controller.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_controller">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::controller</a>;
<b>use</b> <a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_pair">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::pair</a>;
<b>use</b> <a href="router.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_router">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::router</a>;
<b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0xeb2c1f2586f863cc1a1b71f6489a821473ef5e279bb2e00583ca97a299656fee::math</a>;
<b>use</b> <a href="">0xeb2c1f2586f863cc1a1b71f6489a821473ef5e279bb2e00583ca97a299656fee::utils</a>;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_Zap"></a>

## Resource `Zap`



<pre><code><b>struct</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_Zap">Zap</a> <b>has</b> key
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_NewMaxZapReserveRatioEvent"></a>

## Struct `NewMaxZapReserveRatioEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_NewMaxZapReserveRatioEvent">NewMaxZapReserveRatioEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInEvent"></a>

## Struct `ZapInEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInEvent">ZapInEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInRebalancingEvent"></a>

## Struct `ZapInRebalancingEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapInRebalancingEvent">ZapInRebalancingEvent</a> <b>has</b> drop, store
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapOutEvent"></a>

## Struct `ZapOutEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ZapOutEvent">ZapOutEvent</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INSUFFICIENT_LIQUIDITY_MINT"></a>

Insufficient liquidity to mint


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INSUFFICIENT_LIQUIDITY_MINT">ERROR_INSUFFICIENT_LIQUIDITY_MINT</a>: u64 = 7;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_WMOVE"></a>



<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_WMOVE">WMOVE</a>: <b>address</b> = 0xa;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_AMOUNT_TOO_LOW"></a>

Zap amount too low


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_AMOUNT_TOO_LOW">ERROR_AMOUNT_TOO_LOW</a>: u64 = 1;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INSUFFICIENT_RESERVES"></a>

Insufficient reserves


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INSUFFICIENT_RESERVES">ERROR_INSUFFICIENT_RESERVES</a>: u64 = 3;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INVALID_TOKEN"></a>

Wrong Zap Token


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_INVALID_TOKEN">ERROR_INVALID_TOKEN</a>: u64 = 2;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_MAX_ZAP_RESERVE_RATIO"></a>

Quantity higher than limit


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_MAX_ZAP_RESERVE_RATIO">ERROR_MAX_ZAP_RESERVE_RATIO</a>: u64 = 4;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_NOT_ADMIN"></a>

Not admin


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_NOT_ADMIN">ERROR_NOT_ADMIN</a>: u64 = 8;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_SAME_TOKEN"></a>

Identical tokens


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_SAME_TOKEN">ERROR_SAME_TOKEN</a>: u64 = 6;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_WRONG_TRADE_DIRECTION"></a>

Wrong trade direction


<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_ERROR_WRONG_TRADE_DIRECTION">ERROR_WRONG_TRADE_DIRECTION</a>: u64 = 5;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_MINIMUM_AMOUNT"></a>



<pre><code><b>const</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_MINIMUM_AMOUNT">MINIMUM_AMOUNT</a>: u64 = 1000;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_is_initialized"></a>

## Function `is_initialized`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_is_initialized">is_initialized</a>(): bool
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move"></a>

## Function `zap_in_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move">zap_in_move</a>(sender: &<a href="">signer</a>, lp_token: <b>address</b>, amount_in: u64, token_amount_out_min: u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token"></a>

## Function `zap_in_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token">zap_in_token</a>(sender: &<a href="">signer</a>, token_to_zap: <b>address</b>, token_amount_in: u64, lp_token: <b>address</b>, token_amount_out_min: u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token_rebalancing"></a>

## Function `zap_in_token_rebalancing`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_token_rebalancing">zap_in_token_rebalancing</a>(sender: &<a href="">signer</a>, token0_to_zap: <b>address</b>, token1_to_zap: <b>address</b>, token0_amount_in: u64, token1_amount_in: u64, lp_token: <b>address</b>, token_amount_in_max: u64, token_amount_out_min: u64, is_token0_sold: bool)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move_rebalancing"></a>

## Function `zap_in_move_rebalancing`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_in_move_rebalancing">zap_in_move_rebalancing</a>(sender: &<a href="">signer</a>, token1_to_zap: <b>address</b>, move_amount_in: u64, token1_amount_in: u64, lp_token: <b>address</b>, token_amount_in_max: u64, token_amount_out_min: u64, is_token0_sold: bool)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_move"></a>

## Function `zap_out_move`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_move">zap_out_move</a>(sender: &<a href="">signer</a>, lp_token: <b>address</b>, lp_token_amount: u64, token_amount_out_min: u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_token"></a>

## Function `zap_out_token`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_zap_out_token">zap_out_token</a>(sender: &<a href="">signer</a>, lp_token: <b>address</b>, token_to_receive: <b>address</b>, lp_token_amount: u64, token_amount_out_min: u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_update_max_zap_reserve_ratio"></a>

## Function `update_max_zap_reserve_ratio`



<pre><code><b>public</b> entry <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_update_max_zap_reserve_ratio">update_max_zap_reserve_ratio</a>(sender: &<a href="">signer</a>, max_zap_reserve_ratio: u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_swap"></a>

## Function `estimate_zap_in_swap`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_swap">estimate_zap_in_swap</a>(token_to_zap: <b>address</b>, token_amount_in: u64, lp_token: <b>address</b>): (u64, u64, <b>address</b>)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_rebalancing_swap"></a>

## Function `estimate_zap_in_rebalancing_swap`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_in_rebalancing_swap">estimate_zap_in_rebalancing_swap</a>(token0_to_zap: <b>address</b>, token1_to_zap: <b>address</b>, token0_amount_in: u64, token1_amount_in: u64, lp_token: <b>address</b>): (u64, u64, bool)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_out_swap"></a>

## Function `estimate_zap_out_swap`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="zap.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_zap_estimate_zap_out_swap">estimate_zap_out_swap</a>(lp_token: <b>address</b>, lp_token_amount: u64, token_to_receive: <b>address</b>): (u64, u64, <b>address</b>)
</code></pre>
