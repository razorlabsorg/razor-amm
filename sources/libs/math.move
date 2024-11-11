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