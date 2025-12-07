`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^2) Multiply with Shared Factors
// Part of Canright AES S-box Implementation
//
// multiply in GF(2^2), shared factors,
// using normal basis [Omega^2,Omega]
////////////////////////////////////////////////////////////////////////////////

module GF_MULS_2 ( A, ab, B, cd, Q );
  input [1:0] A;
  input ab;
  input [1:0] B;
  input cd;
  output [1:0] Q;
  wire abcd, p, q;
  assign abcd = ~(ab & cd);  /* note:~& syntax for NAND won't compile */
  assign p = (~(A[1] & B[1])) ^ abcd;
  assign q = (~(A[0] & B[0])) ^ abcd;
  assign Q = { p, q };
endmodule
