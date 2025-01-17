
<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library"></a>

# Module `0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::oracle_library`



-  [Function `current_block_timestamp`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_block_timestamp)
-  [Function `current_cumulative_prices`](#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_cumulative_prices)


<pre><code><b>use</b> <a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_amm_pair">0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a::amm_pair</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0xae5ff4c02c7ae43f57c8502c6623747d81bb7dbc6613152eca987a7e1f930727::math</a>;
<b>use</b> <a href="">0xae5ff4c02c7ae43f57c8502c6623747d81bb7dbc6613152eca987a7e1f930727::uq64x64</a>;
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_block_timestamp"></a>

## Function `current_block_timestamp`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_block_timestamp">current_block_timestamp</a>(): u64
</code></pre>



<a id="0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_cumulative_prices"></a>

## Function `current_cumulative_prices`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="oracle_library.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_oracle_library_current_cumulative_prices">current_cumulative_prices</a>(pair: <a href="_Object">object::Object</a>&lt;<a href="pair.md#0x133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a_amm_pair_Pair">amm_pair::Pair</a>&gt;): (u128, u128, u64)
</code></pre>
