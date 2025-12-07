`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Inverse Operation
// Part of Canright AES S-box Implementation
//
// Inverse operation in GF(2^4)/GF(2^2)
////////////////////////////////////////////////////////////////////////////////

module GF_INV_4 ( A, Q );
  input [3:0] A; output [3:0] Q;
  wire [1:0] a, b, c,d,p,q;
  wire sa, sb, sd; /* for shared factors in multipliers */

  assign a = A[3:2]; assign b = A[1:0];
  assign sa = a[1] ^ a[0];
  assign sb = b[1] ^ b[0];
  /* optimize this section as shown below
    GF_MULS_2 abmul(a, sa, b, sb, ab);
    GF_SQ_2 absq( (a ^ b), ab2);
    GF_SCLW2_2 absclN( ab2, ab2N);
    GF_SQ_2 dinv( (ab ^ ab2N), d);
  */
  assign c = { /* note: ~| syntax for NOR won't compile */
    ~(a[1] | b[1]) ^ (~(sa &  sb)) ,
    ~(sa | sb) ^ (~(a[0] & b[0])) };
  GF_SQ_2 csq(c, d);
  /* end of optimization */

  assign sd = d[1] ^ d[0];
  GF_MULS_2 pmul(d, sd, b, sb, p);
  GF_MULS_2 qmul(d, sd, a, sa, q);
  assign Q = { p, q };
endmodule
