`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^2) Square Operation
// Part of Canright AES S-box Implementation
//
// square in GF(2^2), using normal basis [Omega^2,Omega]
// inverse is the same as square in GF(2^2), using any normal basis
////////////////////////////////////////////////////////////////////////////////

module GF_SQ_2 ( A, Q );
  input [1:0] A;
  output [1:0] Q;

  assign Q = { A[0], A[1] };
endmodule
