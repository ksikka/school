/* 
 * CS:APP Data Lab 
 * 
 * Karan Sikka - ksikka
 * 
 * bits.c - Source file with your solutions to the Lab.
 *          This is the file you will hand in to your instructor.
 *
 * WARNING: Do not include the <stdio.h> header; it confuses the dlc
 * compiler. You can still use printf for debugging without including
 * <stdio.h>, although you might get a compiler warning. In general,
 * it's not good practice to ignore compiler warnings, but in this
 * case it's OK.  
 */

#if 0
/*
 * Instructions to Students:
 *
 * STEP 1: Read the following instructions carefully.
 */

You will provide your solution to the Data Lab by
editing the collection of functions in this source file.

INTEGER CODING RULES:
 
  Replace the "return" statement in each function with one
  or more lines of C code that implements the function. Your code 
  must conform to the following style:
 
  int Funct(arg1, arg2, ...) {
      /* brief description of how your implementation works */
      int var1 = Expr1;
      ...
      int varM = ExprM;

      varJ = ExprJ;
      ...
      varN = ExprN;
      return ExprR;
  }

  Each "Expr" is an expression using ONLY the following:
  1. Integer constants 0 through 255 (0xFF), inclusive. You are
      not allowed to use big constants such as 0xffffffff.
  2. Function arguments and local variables (no global variables).
  3. Unary integer operations ! ~
  4. Binary integer operations & ^ | + << >>
    
  Some of the problems restrict the set of allowed operators even further.
  Each "Expr" may consist of multiple operators. You are not restricted to
  one operator per line.

  You are expressly forbidden to:
  1. Use any control constructs such as if, do, while, for, switch, etc.
  2. Define or use any macros.
  3. Define any additional functions in this file.
  4. Call any functions.
  5. Use any other operations, such as &&, ||, -, or ?:
  6. Use any form of casting.
  7. Use any data type other than int.  This implies that you
     cannot use arrays, structs, or unions.

 
  You may assume that your machine:
  1. Uses 2s complement, 32-bit representations of integers.
  2. Performs right shifts arithmetically.
  3. Has unpredictable behavior when shifting an integer by more
     than the word size.

EXAMPLES OF ACCEPTABLE CODING STYLE:
  /*
   * pow2plus1 - returns 2^x + 1, where 0 <= x <= 31
   */
  int pow2plus1(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     return (1 << x) + 1;
  }

  /*
   * pow2plus4 - returns 2^x + 4, where 0 <= x <= 31
   */
  int pow2plus4(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     int result = (1 << x);
     result += 4;
     return result;
  }

FLOATING POINT CODING RULES

For the problems that require you to implent floating-point operations,
the coding rules are less strict.  You are allowed to use looping and
conditional control.  You are allowed to use both ints and unsigneds.
You can use arbitrary integer and unsigned constants.

You are expressly forbidden to:
  1. Define or use any macros.
  2. Define any additional functions in this file.
  3. Call any functions.
  4. Use any form of casting.
  5. Use any data type other than int or unsigned.  This means that you
     cannot use arrays, structs, or unions.
  6. Use any floating point data types, operations, or constants.


NOTES:
  1. Use the dlc (data lab checker) compiler (described in the handout) to 
     check the legality of your solutions.
  2. Each function has a maximum number of operators (! ~ & ^ | + << >>)
     that you are allowed to use for your implementation of the function. 
     The max operator count is checked by dlc. Note that '=' is not 
     counted; you may use as many of these as you want without penalty.
  3. Use the btest test harness to check your functions for correctness.
  4. Use the BDD checker to formally verify your functions
  5. The maximum number of ops for each function is given in the
     header comment for each function. If there are any inconsistencies 
     between the maximum ops in the writeup and in this file, consider
     this file the authoritative source.

/*
 * STEP 2: Modify the following functions according the coding rules.
 * 
 *   IMPORTANT. TO AVOID GRADING SURPRISES:
 *   1. Use the dlc compiler to check that your solutions conform
 *      to the coding rules.
 *   2. Use the BDD checker to formally verify that your solutions produce 
 *      the correct answers.
 */


#endif
/* 
 * isAsciiDigit - return 1 if 0x30 <= x <= 0x39 (ASCII codes for characters '0' to '9')
 *   Example: isAsciiDigit(0x35) = 1.
 *            isAsciiDigit(0x3a) = 0.
 *            isAsciiDigit(0x05) = 0.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 3
 */
int isAsciiDigit(int x) {
  /* Two-step process:
     First check that x is between 0x30 and 0x3F,
     by matching the left (32-4) bits to 0x3.
     Then check that x is at most 0x39 by adding 0x6,
     and running a bit check. */
  
  // shift over so bits 5,6 become bits 1,2
  int x1 = x >> 4;
  int x2;
  // see if bit 1 is 1
  int result1 = 1 & x1;
  // shift and repeat to make sure bit 2 is 1.
  x1 = x1 >> 1;
  result1 = result1 & x1;
  // make sure the leftmost bits after those are 0
  x1 = x1 >> 1;
  result1 = (!x1) & result1;

  // shift the range we are checking up by 0x6
  x2 = x + 0x6;
  // bits after the first 6 should all be 0
  x2 = x2 >> 6;
  return result1 & !x2;
}
/* 
 * anyEvenBit - return 1 if any even-numbered bit in word set to 1
 *   Examples anyEvenBit(0xA) = 0, anyEvenBit(0xE) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int anyEvenBit(int x) {
  /* Makes a really big mask by taking advantage of copy/paste
   * style duplication. Then ANDs x with the mask, which will be
   * zero iff there are no even bits. */
  int mask = 0x5;  //0101 in binary;
  // mask is 4 bits long
  mask = (mask << 4) + mask;
  // mask is 8 bits long
  mask = (mask << 8) + mask;
  // mask is 16 bits long
  mask = (mask << 16) + mask;
  // mask is 32 bits long
  // if even bit, will not be 0 after mask
  return !(!(x & mask));
}
/* 
 * copyLSB - set all bits of result to least significant bit of x
 *   Example: copyLSB(5) = 0xFFFFFFFF, copyLSB(6) = 0x00000000
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 5
 *   Rating: 2
 */
int copyLSB(int x) {
  /* Takes advantage of arithmetic right shift.
   * Shifts LSB to the MSB, then shifts right.*/
  x = x << 31;
  x = x >> 31;
  return x;
}
/* 
 * leastBitPos - return a mask that marks the position of the
 *               least significant 1 bit. If x == 0, return 0
 *   Example: leastBitPos(96) = 0x20
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 2 
 */
int leastBitPos(int x) {
  int y = ~x + 1;
  return x & y;
}
/* 
 * divpwr2 - Compute x/(2^n), for 0 <= n <= 30
 *  Round toward zero
 *   Examples: divpwr2(15,1) = 7, divpwr2(-33,4) = -2
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 2
 */
int divpwr2(int x, int n) {
    // Apply bias to x if x < 0, then right shift. 
    int condition = x >> 31;
    int bias = ( 1 << n ) + (~1 + 1);
    x = x + (condition & bias); // will add 0 if x > 0
    return x >> n;
}
/* 
 * conditional - same as x ? y : z 
 *   Example: conditional(2,4,5) = 4
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 16
 *   Rating: 3
 */
int conditional(int x, int y, int z) {
  int ifmask = !(!x);
  int ifmask2;
  ifmask = ifmask << 31;
  ifmask = ifmask >> 31;
  ifmask2 = ~ifmask;
  y = y & ifmask;
  z = z & ifmask2;

  return y + z;
}
/* 
 * isNonNegative - return 1 if x >= 0, return 0 otherwise 
 *   Example: isNonNegative(-1) = 0.  isNonNegative(0) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 3
 */
int isNonNegative(int x) {
  x = x >> 31;
  return (~x) & 1;
}
/* 
 * isGreater - if x > y  then return 1, else return 0 
 *   Example: isGreater(4,5) = 0, isGreater(5,4) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isGreater(int x, int y) {
  // if the signs are different, then
  // return 1 iff x is positive.
  // else, take the difference and return
  // whether the difference is positive
  int x_is_nonneg = !(x >> 31) & 1;
  int y_is_nonneg = !(y >> 31) & 1;

  int different_signs = x_is_nonneg ^ y_is_nonneg;

  int neg = ~y ;//+ 1;
  int difference = x + neg;
  return ((~(difference >> 31) & 1) & !different_signs) + (x_is_nonneg & different_signs) ;
}
/* 
 * absVal - absolute value of x
 *   Example: absVal(-1) = 1.
 *   You may assume -TMax <= x <= TMax
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 10
 *   Rating: 4
 */
int absVal(int x) {
  // if negative, do two's comp.
  // INEFFICIENT
  int sign_bit_mask = x >> 31;

  int negation = ~x + 1;
  return (sign_bit_mask & negation) + (~sign_bit_mask & x); 
}
/*
 * isPower2 - returns 1 if x is a power of 2, and 0 otherwise
 *   Examples: isPower2(5) = 0, isPower2(8) = 1, isPower2(0) = 0
 *   Note that no negative number is a power of 2.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 4
 */
int isPower2(int x) {
  // only a pwr of 2 iff only a single bit is 1
  int filter_neg_mask = ~(x >> 31);
  int is_zero_mask = !(!x) << 31 >> 31;

  int y = ~x + 1;
  int leastBitPos = x & y;

  int different_bits = x ^ leastBitPos;

  return (!different_bits) & filter_neg_mask & is_zero_mask;
}
/*
 * bitCount - returns count of number of 1's in word
 *   Examples: bitCount(5) = 2, bitCount(7) = 3
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 40
 *   Rating: 4
 */
int bitCount(int x) {
  int mask1,
      mask2,
      mask3,
      mask4,
      mask5;

  // 01010101010101010101010101010101
  mask1 = 0x55;
  mask1 = (mask1 << 8) + mask1;
  mask1 = (mask1 << 16) + mask1;
  
  // 00110011001100110011001100110011
  mask2 = 0x33;
  mask2 = (mask2 << 8) + mask2;
  mask2 = (mask2 << 16) + mask2;
 
  // 00001111000011110000111100001111
  mask3 = 0x0F;
  mask3 = (mask3 << 8) + mask3;
  mask3 = (mask3 << 16) + mask3;
  
  // 00000000111111110000000011111111
  mask4 = 0xFF;
  mask4 = (mask4 << 16) + mask4;

  // 00000000000000001111111111111111
  mask5 = ~( (1 << 31) >> 15);

  x = (x & mask1) + ((x >>  1) & mask1);
  x = (x & mask2) + ((x >>  2) & mask2);
  x = (x & mask3) + ((x >>  4) & mask3);
  x = (x & mask4) + ((x >>  8) & mask4);
  x = (x & mask5) + ((x >> 16) & mask5);

  return x;
}
/* 
 * float_neg - Return bit-level equivalent of expression -f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representations of
 *   single-precision floating point values.
 *   When argument is NaN, return argument.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 10
 *   Rating: 2
 */
unsigned float_neg(unsigned uf) {
  int exp = 0xFF & (uf >> 23);
  int mantissa = 0x007FFFFF & uf;

  // case of NaN
  if ((exp == 0xFF) && (mantissa != 0)) {
    return uf;
  }

  // normal case- flip the sign bit
  return uf ^ (1 << 31);
}
/* 
 * float_i2f - Return bit-level equivalent of expression (float) x
 *   Result is returned as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point values.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned float_i2f(int x) {
  int sign, exp, mantissa, base_to_exp, frac_rem, i, highest_power, one_half,
      left_over_digits, num_left_overs, in_mantissa, some_powers_remain;
  /* preprocessing of x */
  // int_min case:
  if (x == 0x80000000) 
    return (1 << 31) + (( 31 + 127 ) << 23); 
  if (x == 0)
    return 0;
  sign = x < 0;
  if ( sign ) { // if negative 
    x = -x;
  }
  x = x & 0x7FFFFFFF;


  // find highest power of two which divides to leave a positive quotient
  highest_power = 0;
  i = x;
  while (i > 1)
  {
    i = i / 2; // same as right shifting by 1
    highest_power += 1;
    // highest possible value of highest_power is 30
  }
  // add bias
  exp = 127 + highest_power;

  // calculate the mantissa
  mantissa = 0;
  x = x - (1 << highest_power); // guaranteed to be nonnegative the first time
  highest_power -= 1;
  // now, x is the numerator of the fraction which needs to be satisfied
  i = 1;
  left_over_digits = 0;
  num_left_overs = 0;
  // first 23 iterations are in mantissa.
  // any iterations after that are to get the left_over_digits
  in_mantissa = 1;
  some_powers_remain = 0;
  while( in_mantissa || some_powers_remain ) {
    in_mantissa = i <= 23;
    some_powers_remain = highest_power >= 0;
    if (in_mantissa) {
      mantissa = mantissa << 1;
      i += 1;
    } else {
      left_over_digits = left_over_digits << 1;
      num_left_overs += 1;
    }
    if( some_powers_remain ) {
      base_to_exp = 1 << highest_power; // safe because max possible value is 30
      frac_rem = x - base_to_exp;
      if (frac_rem >= 0) {
        mantissa += 1 * in_mantissa;
        left_over_digits += 1 * (!in_mantissa);
        x = frac_rem;
      }
      highest_power -= 1;
    }
  }
  // rounding
  // get the remaining bits
  // if isPowerOfTwo, round to even
  // else if greater than 1, round up
  // else truncate
  if(num_left_overs) {
    one_half = 1 << (num_left_overs - 1); // save this for shifting later

    // check for round-even case
    if (left_over_digits >=  one_half) {
      if (left_over_digits == one_half) {
        // if last digit is 1, add to mantissa to make last digit 0
        // note: if mantissa is full of 1s, then exp will += 1, and m = 0
        mantissa += (mantissa & 1);
      }
      else {
        mantissa += 1;
      }
    }
  }
  return (sign << 31) + (exp << 23) + mantissa;
}
