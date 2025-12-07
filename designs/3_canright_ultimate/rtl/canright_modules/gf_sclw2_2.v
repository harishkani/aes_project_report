`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^2) Scale by Omega^2
// Part of Canright AES S-box Implementation
//
// scale by w^2 = Omega^2 in GF(2^2), using normal basis [Omega^2,Omega]
////////////////////////////////////////////////////////////////////////////////

module GF_SCLW2_2 ( A, Q );
  input [1:0] A;
  output [1:0] Q;
  assign Q = { A[0], (A[1] ^ A[0]) };
endmodule
