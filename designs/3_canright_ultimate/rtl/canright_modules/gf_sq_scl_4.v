`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Square and Scale by Nu
// Part of Canright AES S-box Implementation
//
// square & scale by nu in GF(2^4)/GF(2^2),
// in the normal basis [alpha^8, alpha^2]:
//
// nu = beta^8 = N^2*alpha^2, N = w^2
////////////////////////////////////////////////////////////////////////////////

module GF_SQ_SCL_4 ( A, Q );
  input [3:0] A;
  output [3:0] Q;
  wire [1:0] a, b, ab2, b2, b2N2;
  assign a = A[3:2];
  assign b = A[1:0];
  GF_SQ_2 absq(a ^ b, ab2);
  GF_SQ_2 bsq(b, b2);
  GF_SCLW_2 bmulN2(b2, b2N2);

  assign Q = { ab2, b2N2 };
endmodule
