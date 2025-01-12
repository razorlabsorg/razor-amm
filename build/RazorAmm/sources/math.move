/*
 * A library for performing various math operations
*/
module razor_amm::math {
  /// Largest possible u128 number
  const MAX_U128: u128 = 340282366920938463463374607431768211455;

  // sqrt function
  public fun sqrt(x: u64, y: u64): u64 {
    sqrt_128((x as u128) * (y as u128))
  }

  /// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
  public fun sqrt_128(y: u128): u64 {
    if (y < 4) {
      if (y == 0) {
        0
      } else {
        1
      }
    } else {
      let z = y;
      let x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      };
      (z as u64)
    }
  }

  fun sqrt_256(x: u256): u256 {
    if (x == 0) return 0;

    let xx = x;
    let r: u256 = 1;

    // Perform binary search for the square root
    if (xx >= 0x100000000000000000000000000000000) {
      xx = xx >> 128;
      r = r << 64;
    };
    if (xx >= 0x10000000000000000) {
      xx = xx >> 64;
      r = r << 32;
    };
    if (xx >= 0x100000000) {
      xx = xx >> 32;
      r = r << 16;
    };
    if (xx >= 0x10000) {
      xx = xx >> 16;
      r = r << 8;
    };
    if (xx >= 0x100) {
      xx = xx >> 8;
      r = r << 4;
    };
    if (xx >= 0x10) {
      xx = xx >> 4;
      r = r << 2;
    };
    if (xx >= 0x8) {
      r = r << 1;
    };

    // Newton's method iterations
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;

    let r1 = x / r;

    if (r < r1) { r } else { r1 }
  }

  /// return Math.min
  public fun min(x:u64, y:u64): u64 {
    if (x < y) return x else return y
  }

  /// Add but allow overflow
  public fun overflow_add(a: u128, b: u128): u128 {
    let r = MAX_U128 - b;
    if (r < a) {
      return a - r - 1
    };

    r = MAX_U128 - a;
    if (r < b) {
      return b - r - 1
    };

    a + b
  }

  // Check if mul maybe overflow
  // The result maybe false positive
  public fun is_overflow_mul(a: u128, b: u128): bool {
    MAX_U128 / b <= a
  }
}