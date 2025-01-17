
<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory"></a>

# Module `0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::factory`



-  [Resource `Factory`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_Factory)
-  [Struct `PairCreatedEvent`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_PairCreatedEvent)
-  [Constants](#@Constants_0)
-  [Function `is_initialized`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_is_initialized)
-  [Function `create_pair`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_create_pair)
-  [Function `all_pairs_length`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_length)
-  [Function `all_pairs`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs)
-  [Function `all_pairs_paginated`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_paginated)
-  [Function `get_pair`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_pair)
-  [Function `pair_for`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_for)
-  [Function `get_reserves`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_reserves)
-  [Function `pair_exists`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists)
-  [Function `pair_exists_safe`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_safe)
-  [Function `pair_exists_for_frontend`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_for_frontend)
-  [Function `pause`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pause)
-  [Function `unpause`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_unpause)
-  [Function `set_admin`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_set_admin)
-  [Function `claim_admin`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_claim_admin)


<pre><code><b>use</b> <a href="controller.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_controller">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::controller</a>;
<b>use</b> <a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_pair">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::pair</a>;
<b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::smart_vector</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0xa08003c4b388cecfe32d8b8ccf6b0dfaf84b449860895d3bb0a0c841798f62d0::sort</a>;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_Factory"></a>

## Resource `Factory`



<pre><code><b>struct</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_Factory">Factory</a> <b>has</b> key
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_PairCreatedEvent"></a>

## Struct `PairCreatedEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_PairCreatedEvent">PairCreatedEvent</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_ERROR_IDENTICAL_ADDRESSES"></a>

Identical Addresses


<pre><code><b>const</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_ERROR_IDENTICAL_ADDRESSES">ERROR_IDENTICAL_ADDRESSES</a>: u64 = 1;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_ERROR_PAIR_EXISTS"></a>

The pair already exists


<pre><code><b>const</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_ERROR_PAIR_EXISTS">ERROR_PAIR_EXISTS</a>: u64 = 2;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_is_initialized"></a>

## Function `is_initialized`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_is_initialized">is_initialized</a>(): bool
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_create_pair"></a>

## Function `create_pair`



<pre><code><b>public</b> entry <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_create_pair">create_pair</a>(sender: &<a href="">signer</a>, tokenA: <b>address</b>, tokenB: <b>address</b>)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_length"></a>

## Function `all_pairs_length`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_length">all_pairs_length</a>(): u64
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs"></a>

## Function `all_pairs`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs">all_pairs</a>(): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_paginated"></a>

## Function `all_pairs_paginated`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_all_pairs_paginated">all_pairs_paginated</a>(start: u64, limit: u64): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_pair"></a>

## Function `get_pair`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_pair">get_pair</a>(tokenA: <b>address</b>, tokenB: <b>address</b>): <b>address</b>
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_for"></a>

## Function `pair_for`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_for">pair_for</a>(token_a: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token_b: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_pair_Pair">pair::Pair</a>&gt;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_reserves"></a>

## Function `get_reserves`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_get_reserves">get_reserves</a>(token_a: <b>address</b>, token_b: <b>address</b>): (u64, u64)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists"></a>

## Function `pair_exists`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists">pair_exists</a>(tokenA: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, tokenB: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_safe"></a>

## Function `pair_exists_safe`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_safe">pair_exists_safe</a>(tokenA: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, tokenB: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_for_frontend"></a>

## Function `pair_exists_for_frontend`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pair_exists_for_frontend">pair_exists_for_frontend</a>(<a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_pair">pair</a>: <b>address</b>): bool
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pause"></a>

## Function `pause`



<pre><code><b>public</b> entry <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_pause">pause</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_unpause"></a>

## Function `unpause`



<pre><code><b>public</b> entry <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_unpause">unpause</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_set_admin"></a>

## Function `set_admin`



<pre><code><b>public</b> entry <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_set_admin">set_admin</a>(<a href="">account</a>: &<a href="">signer</a>, admin: <b>address</b>)
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_claim_admin"></a>

## Function `claim_admin`



<pre><code><b>public</b> entry <b>fun</b> <a href="factory.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_factory_claim_admin">claim_admin</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>
