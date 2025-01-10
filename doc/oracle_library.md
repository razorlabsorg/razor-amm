
<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library"></a>

# Module `0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839::oracle_library`



-  [Function `current_block_timestamp`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math">0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839::math</a>;
<b>use</b> <a href="pair.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_pair">0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839::pair</a>;
<b>use</b> <a href="uq64x64.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_uq64x64">0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839::uq64x64</a>;
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(<a href="pair.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_pair_Pair">pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
