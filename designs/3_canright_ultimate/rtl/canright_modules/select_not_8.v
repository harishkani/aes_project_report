`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// 8-bit Select and Invert
// Part of Canright AES S-box Implementation
//
// select and invert (NOT) byte, using MUX21I
////////////////////////////////////////////////////////////////////////////////

module SELECT_NOT_8 ( A, B, s, Q );
  input [7:0] A;
  input [7:0] B;
  input s;
  output [7:0] Q;
  MUX21I m7(A[7], B[7], s, Q[7]);
  MUX21I m6(A[6], B[6], s, Q[6]);
  MUX21I m5(A[5], B[5], s, Q[5]);
  MUX21I m4(A[4], B[4], s, Q[4]);
  MUX21I m3(A[3], B[3], s, Q[3]);
  MUX21I m2(A[2], B[2], s, Q[2]);
  MUX21I m1(A[1], B[1], s, Q[1]);
  MUX21I m0(A[0], B[0], s, Q[0]);
endmodule
