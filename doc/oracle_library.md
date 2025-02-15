
<a id="0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library"></a>

# Module `0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992::oracle_library`



-  [Function `current_block_timestamp`](#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="">0x16f014d37f7d8455c49d587bfc93a26eba6e3f02f1eb391e6afa620b8ffdd91d::fixedpoint64</a>;
<b>use</b> <a href="">0x16f014d37f7d8455c49d587bfc93a26eba6e3f02f1eb391e6afa620b8ffdd91d::math</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="pair.md#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_amm_pair">0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992::amm_pair</a>;
</code></pre>



<a id="0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(pair: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0xc4e68f29fa608d2630d11513c8de731b09a975f2f75ea945160491b9bfd36992_amm_pair_Pair">amm_pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
