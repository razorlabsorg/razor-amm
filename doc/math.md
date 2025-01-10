
<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math"></a>

# Module `0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839::math`



-  [Constants](#@Constants_0)
-  [Function `sqrt`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt)
-  [Function `sqrt_128`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt_128)
-  [Function `min`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_min)
-  [Function `overflow_add`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_overflow_add)
-  [Function `is_overflow_mul`](#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_is_overflow_mul)


<pre><code></code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_MAX_U128"></a>

Largest possible u128 number


<pre><code><b>const</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_MAX_U128">MAX_U128</a>: u128 = 340282366920938463463374607431768211455;
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt"></a>

## Function `sqrt`



<pre><code><b>public</b> <b>fun</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt">sqrt</a>(x: u64, y: u64): u64
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt_128"></a>

## Function `sqrt_128`

babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)


<pre><code><b>public</b> <b>fun</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_sqrt_128">sqrt_128</a>(y: u128): u64
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_min"></a>

## Function `min`

return Math.min


<pre><code><b>public</b> <b>fun</b> <b>min</b>(x: u64, y: u64): u64
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_overflow_add"></a>

## Function `overflow_add`

Add but allow overflow


<pre><code><b>public</b> <b>fun</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_overflow_add">overflow_add</a>(a: u128, b: u128): u128
</code></pre>



<a id="0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_is_overflow_mul"></a>

## Function `is_overflow_mul`



<pre><code><b>public</b> <b>fun</b> <a href="math.md#0x703c20063317af987ab7fc191103d7cd27369ee1322a90d23b174ee393ca9839_math_is_overflow_mul">is_overflow_mul</a>(a: u128, b: u128): bool
</code></pre>
