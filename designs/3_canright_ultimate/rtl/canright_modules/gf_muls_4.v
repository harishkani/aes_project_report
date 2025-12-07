`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Multiply with Shared Factors
// Part of Canright AES S-box Implementation
//
// multiply in GF(2^4)/GF(2^2), shared factors, basis [alpha^8, alpha^2]
////////////////////////////////////////////////////////////////////////////////

module GF_MULS_4 ( A, a, Al, Ah, aa, B, b, Bl, Bh, bb, Q );
  input [3:0] A;
  input [1:0] a;
  input Al;
  input Ah;
  input aa;
  input [3:0] B;
  input [1:0] b;
  input Bl;
  input Bh;
  input bb;
  output [3:0] Q;
  wire [1:0] ph, pl, ps, p;
  wire t;

  GF_MULS_2 himul(A[3:2], Ah, B[3:2], Bh, ph);
  GF_MULS_2 lomul(A[1:0], Al, B[1:0], Bl, pl);
  GF_MULS_SCL_2 summul( a, aa, b, bb, p);
  assign Q = { (ph ^ p), (pl ^ p) };
endmodule
