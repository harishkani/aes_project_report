`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^2) Scale by Omega
// Part of Canright AES S-box Implementation
//
// scale by w = Omega in GF(2^2), using normal basis [Omega^2,Omega]
////////////////////////////////////////////////////////////////////////////////

module GF_SCLW_2 ( A, Q );
  input [1:0] A;
  output [1:0] Q;
  assign Q = { (A[1] ^ A[0]), A[1] };
endmodule
