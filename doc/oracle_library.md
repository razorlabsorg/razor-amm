
<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library"></a>

# Module `0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a::oracle_library`



-  [Function `current_block_timestamp`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="pair.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_pair">0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a::amm_pair</a>;
<b>use</b> <a href="">0xccc5c4272c290d2315a6b34a06715f0b3d563cffae88f6a779140e774e3c35d6::fixedpoint64</a>;
<b>use</b> <a href="">0xccc5c4272c290d2315a6b34a06715f0b3d563cffae88f6a779140e774e3c35d6::math</a>;
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(pair: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x6bf2297de9ab717fde7d25cd4d3c0a05bad9f4d108fc571ff949aaae27bf6d1a_amm_pair_Pair">amm_pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
