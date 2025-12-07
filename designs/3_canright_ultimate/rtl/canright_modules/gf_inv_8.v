`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^8) Inverse Operation
// Part of Canright AES S-box Implementation
//
// inverse in GF(2^8)/GF(2^4), using normal basis [d^16, d]
////////////////////////////////////////////////////////////////////////////////

module GF_INV_8 ( A, Q );
  input [7:0] A;
  output [7:0] Q;
  wire [3:0] a, b, c, d, p, q;
  wire [1:0] sa, sb, sd, t; /* for shared factors in multipliers */
  wire al, ah, aa, bl, bh, bb, dl, dh, dd; /* for shared factors */
  wire c1, c2, c3; /* for temp var */

  assign a = A[7:4];
  assign b = A[3:0];
  assign sa = a[3:2] ^ a[1:0];
  assign sb = b[3:2] ^ b[1:0];
  assign al = a[1] ^ a[0];
  assign ah = a[3] ^ a[2];
  assign aa = sa[1] ^ sa[0];
  assign bl = b[1] ^ b[0];
  assign bh = b[3] ^ b[2];
  assign bb = sb[1] ^ sb[0];

  /* optimize this section as shown below
  GF_MULS_4 abmul(a, sa, al, ah, aa, b, sb, bl, bh, bb, ab);
  GF_SQ_SCL_4 absq( (a ^ b), ab2);
  GF_INV_4 dinv( (ab ^ ab2), d);
  */
  assign c1 = ~(ah & bh);
  assign c2 = ~(sa[0] & sb[0]);
  assign c3 = ~(aa & bb);
  assign c = {
    (~(sa[0] | sb[0]) ^ (~(a[3] & b[3]))) ^ c1 ^ c3 ,
    (~(sa[1] | sb[1]) ^ (~(a[2] & b[2]))) ^ c1 ^ c2 ,
    (~(al | bl) ^ (~(a[1] & b[1]))) ^ c2 ^ c3 ,
    (~(a[0] | b[0]) ^ (~(al & bl))) ^ (~(sa[1] & sb[1])) ^ c2
    };
  GF_INV_4 dinv( c, d);
  /* end of optimization */
  assign sd = d[3:2] ^ d[1:0];
  assign dl = d[1] ^ d[0];
  assign dh = d[3] ^ d[2];
  assign dd = sd[1] ^ sd[0];
  GF_MULS_4 pmul(d, sd, dl, dh, dd, b, sb, bl, bh, bb, p);
  GF_MULS_4 qmul(d, sd, dl, dh, dd, a, sa, al, ah, aa, q);
  assign Q = { p, q };
endmodule
