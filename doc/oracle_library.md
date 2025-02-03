
<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library"></a>

# Module `0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::oracle_library`



-  [Function `current_block_timestamp`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="">0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d::fixedpoint64</a>;
<b>use</b> <a href="">0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d::math</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="pair.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_pair">0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425::amm_pair</a>;
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(pair: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0xd7f96eefaebffd142905a66d68ea836927b56a95cb424e945ef28cd9353a5425_amm_pair_Pair">amm_pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
