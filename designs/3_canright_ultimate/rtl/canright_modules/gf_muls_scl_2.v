`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^2) Multiply and Scale by N
// Part of Canright AES S-box Implementation
//
// multiply & scale by N in GF(2^2), shared factors, basis [Omega^2,Omega]
////////////////////////////////////////////////////////////////////////////////

module GF_MULS_SCL_2 ( A, ab, B, cd, Q );
  input [1:0] A;
  input ab;
  input [1:0] B;
  input cd;
  output [1:0] Q;
  wire t, p, q;

  assign t = ~(A[0] & B[0]); /* note: ~& syntax for NAND won't compile */
  assign p = (~(ab & cd)) ^ t;
  assign q = (~(A[1] & B[1])) ^ t;
  assign Q = { p, q };
endmodule
