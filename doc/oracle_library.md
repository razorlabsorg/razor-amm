
<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library"></a>

# Module `0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::oracle_library`



-  [Function `current_block_timestamp`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="math.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_math">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::math</a>;
<b>use</b> <a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::pair</a>;
<b>use</b> <a href="uq64x64.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_uq64x64">0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283::uq64x64</a>;
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(<a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x4b1bf00e6b8dc4a7bc00f9dc02e5da424236afad275c8833b48c54b0496fd283_pair_Pair">pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
