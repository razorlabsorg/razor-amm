
<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library"></a>

# Module `0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::oracle_library`



-  [Function `current_block_timestamp`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_block_timestamp)
-  [Function `current_cummulative_prices`](#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_cummulative_prices)


<pre><code><b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="math.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_math">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::math</a>;
<b>use</b> <a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::pair</a>;
<b>use</b> <a href="uq64x64.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_uq64x64">0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31::uq64x64</a>;
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_cummulative_prices"></a>

## Function `current_cummulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_oracle_library_current_cummulative_prices">current_cummulative_prices</a>(<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair">pair</a>: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x380cc51342dc20d61af1a05abbd3a4ba718e555ef8c01f1337698180d5ecff31_pair_Pair">pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
